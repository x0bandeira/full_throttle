require "redis"
require "throttle/version"
require "throttle/instance"
require "throttle/redis_script"

module Throttle
  class << self
    attr_accessor :default_redis_client,
                  :default_timeout,
                  :default_polling

    def for(key, max_per_second, opts = {}, &block)
      Instance.new(key, max_per_second, opts).limit(&block)
    end
  end
end
