local current = tonumber(ARGV[1])
local max = tonumber(ARGV[2])
local t = tonumber(redis.call("get", KEYS[1] .. ":t")) or current
local c = tonumber(redis.call("get", KEYS[1] .. ":c")) or 0
if current - t >= 1 then
  redis.call("mset", KEYS[1] .. ":t", current, KEYS[1] .. ":c", 1)
  return {current, 1, 1}
elseif c >= max then
  return {t, c, 0}
else
  redis.call("mset", KEYS[1] .. ":t", current, KEYS[1] .. ":c", c + 1)
  return {t, c + 1, 1}
end
