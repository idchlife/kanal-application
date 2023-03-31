# Kanal::Application

Kanal::Application is used to hide the complexity of the whole Kanal system and allow you to easily and quickly create
functional bot system.

## Installation

1. Add this into your gemfile:

    `gem "kanal-application"`

2. Run

    `bundle install`

3. Create app.rb file with following contents:

```rb
# File: my_application.rb

require "kanal/application"

class MyApplication < Kanal::ApplicationBase
  def configure(env = {})
    # Core is created automatically and available via .core getter method

    # This is recommended, read more about batteries plugin in Kanal documentation
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    # Register any plugins you want
    core.register_plugin MyFavouritePlugin.new its_params

    # Defining default response
    core.router.default_response do
      body "Hey this is default response!"
    end

    # Writing routes for your interface
    # Kanal Application have special way of writing routes in separate files
    # It is just a simple routes separation mechanism, it does not bring anything
    # out of the ordinary for the Kanal routing
    # See next part of an example to learn how you can write routes in separate file
    add_route_packs_dir "./routes/default.rb"

    # You can add routes in good old way of course
    core.router.configure do
      on :body, equals: "something" do
        ...
      end
    end

    # You as developer define :name here just to use it later for enabling this interface in this
    # app. Example: if you write telegram interface in initialization block, you can name it like
    # :tg_dev_interface or :my_personal_bot or any other name.
    # Block is provided with |core| argument so you can configure and initialize you interface
    register_interface :name do |core|
      interface = MyFavInterface.new core, some_other_argument

      # Initialization block MUST return interface in the end
      interface
    end

    # For app to work one of the registered interfaces should be enabled.
    # You can't enable multiple interfaces at once. Only one should be enabled.
    # If you want your app to run at multiple platforms utilizing multiple interfaces, you can
    # achieve this via environment and multiple processes
    enable_interface :name
  end
end

app = MyApplication.new

app.start ENV
```

4. Create ./routes/default.rb

5. Run

    `ruby my_application.rb`

```rb
# File: ./routes/default.rb

require "kanal/application"

Kanal::RoutePack.configure do
  on :body, contains: "weather" do
    respond do
      body "Weather is nice!"
    end
  end
end

```

Install the gem and add to the application's Gemfile by executing:

    $ bundle add kanal-application

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install kanal-application

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/kanal-application.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
