require "spec_helper"

describe Throttle::Instance do
  let(:counter)  { double(:counter, count: nil) }
  let(:strategy) { double(:throttle_strategy) }
  let(:polling)  { 1 }
  let(:timeout)  { 1 }
  let(:key)      { "test" }

  subject do
    described_class.new(strategy, polling, timeout)
  end

  it "executes block if throttle strategy returns true" do
    expect(strategy).to receive(:acquire).
      exactly(3).times.and_return([true, :na, :na])
    expect(counter).to receive(:count).exactly(3).times

    3.times { subject.limit { counter.count } }
  end

  it "passes bucket count and time to block if it has arity" do
    3.times do |n|
      expect(strategy).to receive(:acquire).
        and_return([true, n, t = Time.now])

      subject.limit do |count, time|
        expect(count).to eq n
        expect(time).to  eq t
      end
    end
  end

  it "raises error if can't acquire before timeout" do
    expect(strategy).to receive(:acquire).
      once.and_return([false, :na, :na])
    expect(counter).to_not receive(:count)

    expect  { subject.limit { counter.count } }.to raise_error(Throttle::ThrottledError)
  end

  describe "retrying" do
    let(:timeout)    { 0.60 }
    let(:expected_repetition) { 4 }
    let(:polling)    { timeout / expected_repetition }

    it "retries once every `polling` seconds up to `timeout` seconds" do
      expect(strategy).to receive(:acquire).
        exactly(expected_repetition).times.and_return([false, :na, :na],
                                                      [false, :na, :na],
                                                      [false, :na, :na],
                                                      [true, :na, :na])

      subject.limit { counter.count }
    end
  end

  it "returns status" do
    expect(strategy).to receive(:status).and_return(:arbitrary_status)
    expect(subject.status).to eq :arbitrary_status
  end
end
