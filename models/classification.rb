class Classification

  def self.classification
    @classification ||= Ggi::Classification.new
  end

  def self.autocomplete(search_term)
    classification.autocomplete(search_term)
  end

  def self.taxa
    classification.taxa.values
  end

  def self.find(taxon_id)
    classification.find(taxon_id)
  end

  def self.search(search_term)
    classification.search(search_term)
  end

  def self.roots
    classification.roots
  end

  def self.ancestors_of(taxon)
    classification.ancestors_of(taxon)
  end

  def self.children_of(taxon)
    classification.children_of(taxon)
  end

  def self.siblings_of(taxon)
    classification.siblings_of(taxon)
  end

  def self.number_of_families_under(taxon)
    classification.number_of_families_under(taxon)
  end

end
