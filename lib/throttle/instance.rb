require "timeout"

module Throttle
  class Instance
    def initialize(key, polling, timeout, &strategy)
      @key = key
      @polling = polling
      @timeout = timeout
      @strategy = strategy
    end

    def limit(&block)
      timeout(@timeout) do
        loop do
          return yield if green?
          sleep @polling
        end
      end

    rescue Timeout::Error
      raise Throttle::ThrottledError, "can't execute \"#{@key}\" at this time"
    end

    private
    def green?
      @strategy.call(@key)
    end
  end
end
