require 'json'
require 'yaml'
require 'csv'
require 'rest-client'

class Ggi

  def self.config
    return @config if @config
    conf = YAML.load(File.read(File.expand_path('../config/config.yml', 
                                                __FILE__)))
    @config = OpenStruct.new(conf)
  end
end

puts "** Loading environment."

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
Dir.glob(File.join(File.dirname(__FILE__), 'models', '**', '*.rb')) do |app|
  require File.basename(app, '.*')
end
