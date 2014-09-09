require "spec_helper"

describe Throttle::Instance do
  let(:redis) { Redis.current }
  let(:time)  { Time.now }

  subject { described_class.new("test", 3, timeout: 0.5, polling: 0.5, redis: redis) }

  it "limits how many times something can be called by second" do
    mock = double(:counter)

    expect(mock).to receive(:count).exactly(3).times
    at(time) do
      3.times { subject.limit { mock.count } }
      expect { subject.limit { mock.count } }.to raise_error(Timeout::Error)
    end

    expect(mock).to receive(:count).exactly(3).times
    at(time + 1) do
      3.times { subject.limit { mock.count } }
      expect { subject.limit { mock.count } }.to raise_error(Timeout::Error)
    end
  end
end
