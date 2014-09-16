require "spec_helper"

describe Throttle::RedisScript do
  let(:redis) { Redis.current }
  let(:time)  { Time.now }

  describe "instance" do
    let(:key) { "test" }
    let(:size) { 3 }
    subject! { described_class.new(redis, key, size) }

    describe "managing bucket size" do
      let(:bucket_size) { redis.get(described_class.key(key, :size)).to_i }

      it "sets to default if no value given" do
        subject.set_bucket_size!
        expect(bucket_size).to eq size
      end

      it "sets to given value" do
        subject.set_bucket_size!(100)
        expect(bucket_size).to eq 100
      end
    end

    describe "status" do
      it "returns info on window time, window runs, bucket size" do
        expect(Time).to receive(:at).with(time.to_i).and_return(time)
        redis.set(described_class.key(key, :time),  time.to_i)
        redis.set(described_class.key(key, :count), "12")
        redis.set(described_class.key(key, :size),  "24")
        expect(subject.status).to eq [time, 12, 24]
      end
    end

    describe "acquiring permission" do
      before(:each) { subject.set_bucket_size! }

      it "acquires entry on bucket if possible and returns time, count and flag" do
        Timecop.freeze(time) do |t|
          expect(subject.acquire).to eq [true,  1, t.to_i]
          expect(subject.acquire).to eq [true,  2, t.to_i]
          expect(subject.acquire).to eq [true,  3, t.to_i]
          expect(subject.acquire).to eq [false, 3, t.to_i]
          expect(subject.acquire).to eq [false, 3, t.to_i]
        end
      end

      it "changes bucket size at runtime" do
        Timecop.freeze(time) do |t|
          expect(subject.acquire).to eq [true,  1, t.to_i]
          expect(subject.acquire).to eq [true,  2, t.to_i]
          expect(subject.acquire).to eq [true,  3, t.to_i]
          expect(subject.acquire).to eq [false, 3, t.to_i]

          subject.set_bucket_size!(4)
          expect(subject.acquire).to eq [true,  4, t.to_i]
        end
      end
    end
  end
end
