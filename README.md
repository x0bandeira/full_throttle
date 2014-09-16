# Full Throttle

![](http://www.necessarygames.com/sites/default/files/game_teaser_images/full_throttle_teaser.png)

Pull the breaks on your background processing, protect api calls from abuse, and manage throughput with 0 hassle leveraging Redis to throttle concurrent processes.

Atomicity and thread-safety of throttle guaranteed by good use of Redis.

## Usage

```ruby
response = Throttle.for(:user_info, 200) { api["users/#{id}"].get }
user.update(response)
```

There we have `:user_info` is the id of the throttle, `200` is the number of times that id can be executed in one second. *Full Throttle* is designed for high speed action, not long throttling windows.

__get updated status__

```ruby
instance = Throttle.for(:user_info)
instance.status # [ bucket_time, bucket_count, bucket_size ]
```

__handle or log throttled actions__

```ruby
begin
  Throttle.for(:search_index, 300) { record.update_index! }
rescue Throttle::ThrottledError => e
  ...
end
```

__manage throughput without code pushes__ running on the console or on a cronjob to raise the limits at night and take it easy during the day

```ruby
if (22...7).include?(Time.now.hour)
  Throttle.for(:upstream_sync).set_bucket_size!(500)
end
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'throttle'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install throttle

## Contributing

1. Fork it ( https://github.com/rafaelbandeira3/full_throttle/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
