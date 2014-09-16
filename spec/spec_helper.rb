require File.join(File.dirname(__FILE__), "..", "lib", "throttle")

require "byebug"
require "timecop"

RSpec.configure do |config|
  config.before(:each) do
    keys = Redis.current.scan_each.to_a
    Redis.current.del(keys) if keys.any?
  end
end

