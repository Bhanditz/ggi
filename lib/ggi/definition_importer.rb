# Grabs definitions for the URIs defined in Ggi::Uri.
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
    json = File.read(File.join(__dir__, '..', '..', 'public', 'eol_definitions.json'))
    @@definitions = JSON.parse(json)
    @@definitions.select! { |uri| Ggi::Uri.all.any? { |ggi_uri| ggi_uri.uri == uri["uri"] } }
  end

end
