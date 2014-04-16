class Classification

  def self.classification
    @classification ||= Ggi::Classification.new
  end

  def self.autocomplete(search_term)
    classification.autocomplete(search_term)
  end

  def self.find(taxon_id)
    classification.find(taxon_id)
  end

  def self.search(search_term)
    classification.search(search_term)
  end

  def self.ancestors_of(taxon_id)
    classification.ancestors_of(taxon_id)
  end

  def self.children_of(taxon_id)
    classification.children_of(taxon_id)
  end

end
