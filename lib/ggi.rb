require 'json'
require 'yaml'
require 'csv'
require 'rest-client'
require 'nokogiri'

require_relative 'ggi/version'
require_relative 'ggi/falo_importer'
require_relative 'ggi/classification'

class Ggi

  def self.config
    return @config if @config
    conf = YAML.load(File.read(File.join(__dir__, 
                                         '..', 'config', 'config.yml')))
    @config = OpenStruct.new(conf)
  end

end
