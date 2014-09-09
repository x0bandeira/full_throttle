require "timeout"

module Throttle
  class Instance
    def initialize(key, max_per_second, opts = {})
      @key = "throttle:" << key
      @max_per_second = max_per_second
      @polling = opts[:polling] || Throttle.default_polling
      @timeout = opts[:timeout] || Throttle.default_timeout
      @redis   = opts[:redis]   || Throttle.default_redis_client
    end

    def limit(&block)
      timeout(@timeout) do
        loop do
          return yield if green?
          sleep @polling
        end
      end
    end

    private
    def green?
      t, c, go = RedisScript.run(@redis, @key, @max_per_second)
      go
    end
  end
end
