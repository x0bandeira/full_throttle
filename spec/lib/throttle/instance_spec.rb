require "spec_helper"

describe Throttle::Instance do
  let(:counter) { double(:counter, count: nil) }
  let(:throttle_strategy) { double(:throttle_strategy) }
  let(:polling) { 1 }
  let(:timeout) { 1 }
  let(:key)     { "test" }

  subject do
    strategy = ->(key) { throttle_strategy.call(key) }
    described_class.new(key, polling, timeout, &strategy)
  end

  it "executes block if throttle strategy returns true" do
    expect(throttle_strategy).to receive(:call).
      with(key).exactly(3).times.and_return(true)
    expect(counter).to receive(:count).exactly(3).times

    3.times { subject.limit { counter.count } }
  end

  it "raises error if throttle strategy returns false" do
    expect(throttle_strategy).to receive(:call).
      with(key).once.and_return(false)
    expect(counter).to_not receive(:count)

    expect  { subject.limit { counter.count } }.to raise_error(Throttle::ThrottledError)
  end

  describe "retrying" do
    let(:timeout) { 0.60 }
    let(:polling) { timeout / 4 }

    it "retries once every `polling` seconds up to `timeout` seconds" do
      expect(throttle_strategy).to receive(:call).
        with(key).exactly(4).times.and_return(false, false, false, true)

      subject.limit { counter.count }
    end
  end
end
