# PullRequestBuilder

Integrate your CI pipeline with Open Build Service, being possible to build your PR as package in the trusty OBS!

## Build Status
[![CircleCI](https://circleci.com/gh/vpereira/pull_request_builder.svg?style=svg)](https://app.circleci.com/pipelines/github/vpereira/pull_request_builder)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pull_request_builder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pull_request_builder

## Usage

We have it being used here: https://github.com/openSUSE/obs-tools/tree/master/pull_request_package

Please look our [Wiki](https://github.com/openSUSE/obs-pullrequest-builder) if you need more specific information

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vpereira/pull_request_builder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Thanks

To all contributors from the original code https://github.com/openSUSE/obs-tools/tree/master/pull_request_package

Eduardoj, coolo, ChrisBr and many others!
