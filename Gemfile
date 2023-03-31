# frozen_string_literal: true

source "https://rubygems.pieq.space"

# Specify your gem's dependencies in kanal.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "kanal", ">= 0.4.3"

# gem "method_source", "1.0.0"

# Move outside to plugin repo
# gem 'telegram-bot-ruby'

group :development do
  gem "rubocop", "~> 1.21"
  gem "ruby-debug-ide"
  gem "solargraph"
  gem "yard"
  gem "debase"
end

group :test do
  gem "simplecov", require: false
end
