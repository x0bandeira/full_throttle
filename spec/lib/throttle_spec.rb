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

  shared_examples "Throttle API" do
    it "initializes throttle with options and limits given block" do
      expect(described_class::RedisScript).to receive(:new).
        with(redis, "#{ns}:#{key}", max).
        and_call_original

      expect(described_class::Instance).to receive(:new).
        with(kind_of(described_class::RedisScript), polling, timeout).
        and_call_original

      expect(counter).to receive(:count)

      described_class.for(key, max, opts) { counter.count }
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
