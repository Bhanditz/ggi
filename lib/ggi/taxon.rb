class Ggi::Taxon

  attr_accessor :score, :left_value, :right_value

  # TODO - Taxon probably doesn't need to know about these. Might be worth
  # extracting these to an "Eol" class of some kind, but I would wait until
  # more information of this kind is required.
  #
  # These are strings used by EOL in URLs, representing the standard sizes
  # of images:
  IMG_SIZE = {
    large: '580_360',
    thumb: '98_68',
    icon: '88_88'
  }

  def initialize(taxon_hash)
    @taxon_hash = taxon_hash
    @score = 0
  end

  def self.find(id)
    Ggi::Classification.find(id)
  end

  def self.find_by_name(name)
    Ggi::Classification.search(name)
  end

  def self.all
    Ggi::Classification.taxa
  end

  def self.autocomplete(search_term)
    Ggi::Classification.autocomplete(search_term)
  end

  def name
    @taxon_hash[:dwc_record]['scientificName']
  end

  def rank
    (@taxon_hash[:dwc_record]['taxonRank'] || @taxon_hash[:taxonRank] || '').
      capitalize
  end

  def family?
    rank == 'Family'
  end

  def source
    @taxon_hash[:dwc_record]['bibliographicCitation']
  end

  def image
    if @taxon_hash[:bestImage] && @taxon_hash[:bestImage][:eolThumbnailURL]
      @taxon_hash[:bestImage][:eolThumbnailURL].gsub!(/#{IMG_SIZE[:thumb]}/, IMG_SIZE[:large])
      @taxon_hash[:bestImage]
    end
  end

  def thumbnail
    if image
      image[:eolThumbnailURL].gsub(/#{IMG_SIZE[:large]}/, IMG_SIZE[:icon])
    end
  end

  def classification_summary
    # roots will return an empty array [ ]
    [ ancestors.first, ancestors.last ].compact.uniq
  end

  def ancestors
    Ggi::Classification.ancestors_of(self)
  end

  def children
    Ggi::Classification.children_of(self)
  end

  def siblings
    Ggi::Classification.siblings_of(self)
  end

  def number_of_families
    Ggi::Classification.number_of_families_under(self)
  end

  def measurements
    @taxon_hash[:measurements] || []
  end

  def vernacularNames
    @taxon_hash[:vernacularNames] || []
  end

  def english_vernacular_name
    preferred_english_vernacular = vernacularNames.find { |n| n[:language] == 'en' && n[:eol_preferred] }
    preferred_english_vernacular ? preferred_english_vernacular[:vernacularName].capitalize : nil
  end

  def method_missing(meth, *args, &block)
    if @taxon_hash.has_key?(meth.to_sym)
      @taxon_hash[meth.to_sym]
    else
      super
    end
  end

  def name_matches?(matched_name)
    (matched_name.casecmp(name) == 0) ||
      (english_vernacular_name &&
        (matched_name.casecmp(english_vernacular_name) == 0))
  end

end
