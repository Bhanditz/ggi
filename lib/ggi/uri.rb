class Ggi::Uri

  attr_reader :short_name, :long_name, :uri

  def self.all
    @all ||= [
      Ggi::Uri.new(short_name: 'BHL', long_name: 'BHL pages', uri: 'http://eol.org/schema/terms/NumberReferencesInBHL'),
      Ggi::Uri.new(short_name: 'BOLD', long_name: 'BOLD records', uri: 'http://eol.org/schema/terms/NumberPublicRecordsInBOLD'),
      Ggi::Uri.new(short_name: 'EOL', long_name: 'EOL rich pages', uri: 'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL'),
      Ggi::Uri.new(short_name: 'GBIF', long_name: 'GBIF records', uri: 'http://eol.org/schema/terms/NumberRecordsInGBIF'),
      Ggi::Uri.new(short_name: 'NCBI', long_name: 'GenBank sequences', uri: 'http://eol.org/schema/terms/NumberOfSequencesInGenBank'),
      Ggi::Uri.new(short_name: 'GGBN', long_name: 'GGBN records', uri: 'http://eol.org/schema/terms/NumberSpecimensInGGBN')
    ]
  end

  def self.uris
    @all.map(&:uri)
  end

  def self.short_names
    @all.map(&:short_name)
  end

  def self.long_names
    @all.map(&:long_name)
  end

  def self.find_by_uri(uri)
    @all.find { |instance| instance.uri == uri }
  end

  def self.find(short_name)
    @all.find { |instance| instance.short_name == short_name }
  end

  def initialize(opts)
    @short_name = opts[:short_name]
    @long_name = opts[:long_name]
    @uri = opts[:uri]
  end

  def sym
    @short_name.downcase.to_sym
  end

  # TODO - this should be a singleton call to EOL's database
  def definition
    nil
  end

  # examples:

  if (false)
    Ggi::Uri.bhl.uri
  end

  # NOTE - keep this at the end of the file.
  all.each do |instance|
    define_singleton_method(instance.sym) do
      instance
    end
  end

end
