require "spec_helper"

describe Throttle::RedisScript do
  let(:redis) { Redis.current }
  let(:time)  { Time.now }

  describe "instance" do
    let(:key) { "test" }
    let(:size) { 3 }
    subject! { described_class.new(redis, key) }

    describe "managing bucket size" do
      let(:bucket_size) { redis.get(described_class.key(key, :size)).to_i }

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
      before(:each) { Timecop.freeze(time) }
      after(:each)  { Timecop.return }

      it "returns time, count and flag" do
        expect(subject.acquire).to eq [true,  1, time.to_i]
      end

      context do
        before(:each) { subject.set_bucket_size!(3) }
        it "acquires entry on bucket isn't full" do
          expect(subject.acquire).to eq [true,  1, time.to_i]
          expect(subject.acquire).to eq [true,  2, time.to_i]
          expect(subject.acquire).to eq [true,  3, time.to_i]
          expect(subject.acquire).to eq [false, 3, time.to_i]
          expect(subject.acquire).to eq [false, 3, time.to_i]
        end

        it "empties bucket after bucket duration" do
          expect(subject.acquire).to eq [true,  1, time.to_i]
          expect(subject.acquire).to eq [true,  2, time.to_i]
          expect(subject.acquire).to eq [true,  3, time.to_i]
          expect(subject.acquire).to eq [false, 3, time.to_i]

          Timecop.freeze(time + 1)
          expect(subject.acquire).to eq [true,  1, (time + 1).to_i]
        end

        it "changes bucket size at runtime" do
          expect(subject.acquire).to eq [true,  1, time.to_i]
          expect(subject.acquire).to eq [true,  2, time.to_i]
          expect(subject.acquire).to eq [true,  3, time.to_i]
          expect(subject.acquire).to eq [false, 3, time.to_i]

          subject.set_bucket_size!(4)
          expect(subject.acquire).to eq [true,  4, time.to_i]
        end
      end

      it "acquires always if no size set" do
        credibility = ENV["CREDIBLE"] ? Float::INFINITY : 20

        (0..credibility).each {|n| expect(subject.acquire).to eq [true,  n + 1, time.to_i] }
      end
    end
  end
end
