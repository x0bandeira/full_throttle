require "spec_helper"

describe Throttle do
  let(:key)     { :test }
  let(:max)     { 30 }
  let(:polling) { 0.25 }
  let(:timeout) { 1 }
  let(:redis)   { Redis.current }
  let(:ns)      { :throttled_actions }
  let(:counter) { double(:counter, count: nil) }
  let(:opts)    { {} }

  let!(:redis_script) { described_class::RedisScript.new(redis, :foo) }
  let!(:instance)     { described_class::Instance.new(redis_script, polling, timeout) }

  shared_examples "Throttle API" do
    before(:each) do
      expect(described_class::RedisScript).to receive(:new).
        with(redis, "#{ns}:#{key}").
        and_return(redis_script)

      expect(described_class::Instance).to receive(:new).
        with(kind_of(described_class::RedisScript), polling, timeout).
        and_return(instance)
    end

    it "initializes throttle with options" do
      expect(described_class.for(key, max, opts)).to eq instance
    end

    it "initializes and returns limit" do
      block = ->{}
      expect(instance).to receive(:limit).and_yield.and_return(:return)
      expect(described_class.for(key, max, opts, &block)).to eq :return
    end

    it "doesn't set bucket size if none is passed" do
      expect(redis_script).to_not receive(:set_bucket_size!)
      described_class.for(key, nil, opts)
    end
  end

  describe "using options" do
    let(:opts) { {polling: polling, timeout: timeout,  redis: redis, ns: ns} }
    it_behaves_like "Throttle API"
  end

  describe "using defaults" do
    before(:each) do
      Throttle.default_polling = polling
      Throttle.default_timeout = timeout
      Throttle.default_redis_client = redis
      Throttle.default_ns = ns
    end
    it_behaves_like "Throttle API"
  end
end
