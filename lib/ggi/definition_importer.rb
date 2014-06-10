class Ggi::DefinitionImporter 

  def self.import
    Ggi::DefinitionImporter.new.import
  end

  def self.clear_cache
    @@definitions = nil
  end

  # We actually want to do this when the class is loaded:
  self.clear_cache

  def import
    return @@definitions if @@definitions
    json = File.read(File.join(Sinatra::Application.root, 'public', 'eol_definitions.json'))
    @@definitions = JSON.parse(json)
  end

end
