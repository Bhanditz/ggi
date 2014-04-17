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

RSpec.configure do |c|
  c.include Capybara::DSL
end

WebMock.disable_net_connect!(:allow_localhost => true)
