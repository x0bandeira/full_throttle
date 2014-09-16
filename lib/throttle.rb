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

    def for(key, max_per_second = nil, opts = {}, &block)
      polling   = opts[:polling] || Throttle.default_polling
      timeout   = opts[:timeout] || Throttle.default_timeout
      redis     = opts[:redis]   || Throttle.default_redis_client
      namespace = opts[:ns]      || Throttle.default_ns

      strategy = RedisScript.new(redis, "#{namespace}:#{key}")
      strategy.set_bucket_size!(max_per_second) if max_per_second

      instance = Instance.new(strategy, polling, timeout)
      block_given? ? instance.limit(&block) : instance
    end
  end
end
