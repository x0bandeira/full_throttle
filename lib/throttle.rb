require "redis"
require "throttle/version"
require "throttle/instance"
require "throttle/redis_script"

module Throttle
  ThrottledError = Class.new(StandardError)

  class << self
    attr_accessor :default_redis_client,
                  :default_timeout,
                  :default_ns,
                  :default_polling

    def for(key, max_per_second, opts = {}, &block)
      polling   = opts[:polling] || Throttle.default_polling
      timeout   = opts[:timeout] || Throttle.default_timeout
      redis     = opts[:redis]   || Throttle.default_redis_client
      namespace = opts[:ns]      || Throttle.default_ns

      strategy = RedisScript.new(redis, "#{namespace}:#{key}", max_per_second)
      strategy.set_bucket_size!

      instance = Instance.new(strategy, polling, timeout)
      instance.limit(&block)
    end
  end
end
