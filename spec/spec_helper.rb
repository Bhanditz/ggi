require 'coveralls'
Coveralls.wear!

require 'rack/test'
require 'capybara'
require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/webkit'
require 'webmock'
require 'webmock/rspec'

require_relative 'support/helpers'

ENV['RACK_ENV'] = 'test'
require_relative '../application.rb'

Capybara.javascript_driver = :webkit
Capybara.app = Sinatra::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
