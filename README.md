# Textliner

Ruby wrapper gem for the Textline API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'textliner'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install textliner

## Usage

### example Rails integration
```ruby
# in config/initializers/textliner.rb
Textliner.access_token($TEXTLINE_API_TOKEN)

# in app/model/user.rb
class User
  after_create do
    Textliner::Customer
      .create(
        name: name,
        phone_number: phone,
        email: email,
        tags: ["new", "user"])
  end
end

# in some marketing model like app/model/deal.rb
class Deal
  after_update do
    subscribers.each do |subscriber|
      Textliner::Customer
        .by_phone_number(subscriber.phone)
        .posts
        .create(body: "Come check out this awesome new #{deal_name} deal"))
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/textliner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/textliner/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Textliner project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/textliner/blob/master/CODE_OF_CONDUCT.md).
