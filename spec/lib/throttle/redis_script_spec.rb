require "spec_helper"

describe Throttle::RedisScript do
  let(:redis) { Redis.current }
  let(:time)  { Time.now }

  def run_script(*args)
    Throttle::RedisScript.run(*args)
  end

  it "setup needed keys" do
    expect(redis.get("test:t")).to eq nil
    expect(redis.get("test:c")).to eq nil
    at(time) do |t|
      run_script(redis, "test", 1)
      expect(redis.get("test:t")).to eq t.to_s
      expect(redis.get("test:c")).to eq "1"
    end
  end

  it "returns time of throttle window, count of items inside the window,
      flag for inclusion on the window" do
    at(time) do |t|
      expect(run_script(redis, "test", 3)).to eq [t, 1, true]
      expect(run_script(redis, "test", 3)).to eq [t, 2, true]
      expect(run_script(redis, "test", 3)).to eq [t, 3, true]
      expect(run_script(redis, "test", 3)).to eq [t, 3, false]
      expect(run_script(redis, "test", 3)).to eq [t, 3, false]
    end

    at(time + 1) do |t|
      expect(run_script(redis, "test", 3)).to eq [t, 1, true]
      expect(run_script(redis, "test", 3)).to eq [t, 2, true]
      expect(run_script(redis, "test", 3)).to eq [t, 3, true]
      expect(run_script(redis, "test", 3)).to eq [t, 3, false]
      expect(run_script(redis, "test", 4)).to eq [t, 4, true]
    end
  end
end
