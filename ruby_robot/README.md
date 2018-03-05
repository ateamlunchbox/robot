# RubyRobot

Toy code implementing robot interface for ruby coding challenge for Netflix
https://jobs.netflix.com/jobs/864893 (if dead, this URL exists at archive.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_robot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_robot

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Versions

0.1.3 - Fix bundler setup for ruby_robot; move json schemas from 'doc' to 'json_schema'
0.1.2 - Add checks so web app will bind to all interfaces when run under Docker
0.1.1 - Adding bundler as a runtime dependency
0.1.0 - Initial release

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ruby_robot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
