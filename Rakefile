require 'bundler'
require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require_relative 'lib/ggi'
APP_FILE = 'application.rb'
APP_CLASS = 'Sinatra::Application'
require 'sinatra/assetpack/rake'

task :default => :spec

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*spec.rb'
end

desc 'open an irb session preloaded with this library'
task :console do
  sh "irb -I . -r environment.rb"
end
