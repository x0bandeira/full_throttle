require "digest"

module Throttle
  class RedisScript
    SCRIPT      = File.read("lib/throttle.lua").freeze
    SCRIPT_SHA1 = Digest::SHA1.hexdigest(SCRIPT)

    def self.key(key, type)
      "#{@key}:#{type}"
    end

    def initialize(redis, key, default_bucket_size)
      @redis = redis
      @key   = key
      @default_bucket_size = default_bucket_size
    end

    def acquire
      begin
        keys = [key(:size), key(:time), key(:count), key(:duration)]
        go, count, time = @redis.evalsha(SCRIPT_SHA1, keys, [Time.now.utc.to_i])
        [go == 1, count, time]
      rescue Redis::CommandError => e
        raise unless e.message =~ /NOSCRIPT/

        @redis.send("script", "load", SCRIPT)
        acquire
      end
    end

    def status
      time, count, size = @redis.mget(key(:time), key(:count), key(:size))
      [Time.at(time.to_i), count.to_i, size.to_i]
    end

    def set_bucket_size!(val = nil)
      @redis.set(key(:size), val || @default_bucket_size)
    end

    private
    def key(k)
      self.class.key(@key, k)
    end
  end
end
