require "timeout"

module Throttle
  class Instance
    def initialize(strategy, polling, timeout)
      @strategy = strategy
      @polling = polling
      @timeout = timeout
    end

    def limit(&block)
      timeout(@timeout) do
        loop do
          return yield if @strategy.acquire
          sleep @polling
        end
      end

    rescue Timeout::Error
      raise Throttle::ThrottledError, "can't execute at this time"
    end
  end
end
