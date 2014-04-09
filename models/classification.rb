class Classification 

  def self.classification
    @classification ||= Ggi::FaloImporter.new.import
  end

  def self.autocomplete(search_term)
    classification.autocomplete(search_term)
  end

  def self.search(search_term)
    classification.search(search_term)
  end

end
