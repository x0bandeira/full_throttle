require "digest"

module Throttle
  module RedisScript
    SCRIPT      = File.read("lib/throttle.lua").freeze
    SCRIPT_SHA1 = Digest::SHA1.hexdigest(SCRIPT)

    def self.run(redis, key, max_per_second)
      begin
        time, count, go = redis.evalsha(SCRIPT_SHA1, [key], [Time.now.utc.to_i, max_per_second])
        [time, count, go == 1]
      rescue Redis::CommandError => e
        raise unless e.message =~ /NOSCRIPT/

        redis.send("script", "load", SCRIPT)
        run(redis, key, max_per_second)
      end
    end
  end
end
