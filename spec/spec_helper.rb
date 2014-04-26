if ENV['simplecov']
  require 'simplecov'
  SimpleCov.start
else
  require 'coveralls'
  Coveralls.wear!
end

require 'rack/test'
require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/webkit'
require 'webmock'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'
require_relative '../application.rb'

# Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :webkit
Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include Capybara::DSL
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.alias_example_to :expect_it
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end

WebMock.disable_net_connect!(:allow_localhost => true)
