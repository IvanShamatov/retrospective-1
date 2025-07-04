# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 5.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

gem 'jquery-rails', '~> 4.3', '>= 4.3.1'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.2'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'dotenv-rails'
gem 'sentry-raven'

# Authentication
gem 'devise'
gem 'omniauth-alfred', git: 'https://github.com/cybergizer-hq/omniauth-alfred', branch: 'master'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-github'

gem 'strong_migrations', '~> 0.7.8'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rubocop', '~> 1.6.1', require: false
  gem 'rspec-rails', '~> 4.0.1'
  gem 'rspec_junit_formatter'
  gem 'faker', git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'pry'
  gem 'pry-byebug'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.4'
  gem 'rails-erd'
  gem 'letter_opener'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'simplecov', require: false
  gem 'factory_bot_rails'
  gem 'vcr'
  gem 'webmock'
  gem 'test-prof'
  gem 'json_matchers'
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'webpacker', '~> 5'
gem 'rails-assets-bulma', source: 'https://rails-assets.org'
gem 'fog-aws', require: false
gem 'carrierwave', '>= 2.0.0.rc', '< 3.0'
gem 'nanoid'
gem 'action_policy', '~> 0.5.4'
gem 'react-rails'
gem 'active_model_serializers', '~> 0.10.12'
gem 'dry-monads'
gem 'aasm'
gem 'sidekiq'

gem 'graphql', '~> 1.11'
gem 'action_policy-graphql', '~> 0.5'
gem 'graphiql-rails', group: :development
group :test, :development do
  gem 'action-cable-testing'
end

gem 'bullet', group: 'test'
