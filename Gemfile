#!/user/bin/env ruby
# ^ For syntax highlighting.

source 'https://rubygems.org'

gem 'haml', '~> 4.0' # HTML markup
# NOTE - JSON is required in other pieces-parts, but we're being specific:
gem 'json', '~> 1.8' # Input format.
gem 'rack', '~> 1.5'  # Middleware for Sinatra
gem 'rake', '~> 10.2'  # Ruby tasks for command-line invocation
gem 'sinatra', '~> 1.4'  # Application framework
gem 'sinatra-assetpack', '~> 0.3', require: 'sinatra/assetpack'
gem 'rest_client', '~> 1.7', require: 'rest-client'
gem 'nokogiri', '~> 1.6'

group 'development' do
  gem 'debugger', '~> 1.6'  # Duh.
end

group 'production' do
  gem 'unicorn', '~> 4.8'
end

group 'assets' do
  gem 'compass', '~> 0.12'  # A package manager for sass
  gem 'sass', '~> 3.2'  # CSS Markup
  gem 'susy', '~> 1.0'  # CSS Grid and math
  gem 'sassy-buttons', '~> 0.2'  # CSS Buttons
end

group 'test' do
  gem 'capybara', '~> 2.2'  # Makes testing websites much easier
  gem 'capybara-webkit', '~> 1.1' # Headless JS-aware browser for capybara
  # gem 'selenium-webdriver'
  gem 'coveralls', '~> 0.7', require: false
  gem 'rack-test', '~> 0.6'  # Allows rack use in testing
  gem 'rspec', '3.0.0.beta2'  # Testing framework allowing "specifications"
  gem 'webmock', '~> 1.17'
end
