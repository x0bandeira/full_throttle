require "spec_helper"

describe Throttle::RedisScript do
  let(:redis) { Redis.current }
  let(:time)  { Time.now }

  def run_script(*args)
    Throttle::RedisScript.run(*args)
  end

  describe "instance" do
    let(:key) { "test" }
    let(:size) { 3 }
    subject! { described_class.new(redis, key, size) }

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

    it "returns info on window time, window runs, bucket size" do
      expect(Time).to receive(:at).with(time.to_i).and_return(time)
      redis.set(described_class.key(key, :time),  time.to_i)
      redis.set(described_class.key(key, :count), "12")
      redis.set(described_class.key(key, :size),  "24")
      expect(subject.info).to eq [time, 12, 24]
    end
  end
end
