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
          go, count, time = @strategy.acquire
          if go
            return yield(count, time) if block.arity > 0
            return yield
          end
          sleep @polling
        end
      end

    rescue Timeout::Error
      raise Throttle::ThrottledError, "can't execute at this time"
    end

    def status
      @strategy.status
    end
  end
end
