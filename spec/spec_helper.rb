require 'coveralls'
Coveralls.wear!

require 'rack/test'
require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/webkit'

ENV['RACK_ENV'] = 'test'
# TODO - should we be putting both in here?
require_relative '../environment.rb'
require_relative '../application.rb'

Capybara.javascript_driver = :webkit
Capybara.app = Sinatra::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
