local time            = tonumber(ARGV[1])
local bucket_size     = tonumber(redis.call("get", KEYS[1])) or math.huge
local bucket_time     = tonumber(redis.call("get", KEYS[2])) or time
local bucket_count    = tonumber(redis.call("get", KEYS[3])) or 0
local bucket_duration = tonumber(redis.call("get", KEYS[4])) or 1

if time - bucket_time >= bucket_duration then -- reset bucket
  redis.call("mset", KEYS[2], time, KEYS[3], 1)
  return {1, 1, time}
elseif bucket_count >= bucket_size then      -- throttled
  return {0, bucket_count, bucket_time}
else                                         -- good to go
  redis.call("mset", KEYS[2], time, KEYS[3], bucket_count + 1)
  return {1, bucket_count + 1, bucket_time}
end
