class Taxon

  def initialize(taxon_hash)
    @taxon_hash = taxon_hash
    # ancestors is a key of the API response, but its also a
    # convenience method in this class
    @taxon_hash[:api_ancestors] = @taxon_hash[:ancestors]
    set_measurement_labels
  end

  def self.find(id)
    Classification.find(id)
  end

  def self.find_by_name(name)
    Classification.search(name)
  end

  def self.autocomplete(search_term)
    Classification.autocomplete(search_term)
  end

  def set_measurement_labels
    unless @taxon_hash[:measurements].nil?
      @taxon_hash[:measurements].each do |measurement|
        measurement[:label] = case measurement[:label]
          when /genbank/i
            'GenBank sequences'
          when /EOL/
            'EOL rich pages'
          when /GGBN/
            'GGBN records'
          when /GBIF/
            'GBIF records'
        end
      end
    end
  end

  def name
    @taxon_hash[:dwc_record]['scientificName']
  end

  def rank
    (@taxon_hash[:dwc_record]['taxonRank'] || @taxon_hash[:taxonRank] || '').
      capitalize
  end

  def source
    @taxon_hash[:dwc_record]['bibliographicCitation']
  end

  def image
    if @taxon_hash[:bestImage] && @taxon_hash[:bestImage][:eolThumbnailURL]
      @taxon_hash[:bestImage][:eolThumbnailURL].gsub!(/98_68/, '580_360')
      return @taxon_hash[:bestImage]
    end
  end

  def ancestors
    Classification.ancestors_of(@taxon_hash[:id])
  end

  def children
    Classification.children_of(@taxon_hash[:id])
  end

  def siblings
    Classification.siblings_of(@taxon_hash[:id])
  end

  def measurements
    @taxon_hash[:measurements] || []
  end

  def method_missing(meth, *args, &block)
    if @taxon_hash.has_key?(meth.to_sym)
      return @taxon_hash[meth.to_sym]
    end
    super
  end

end
