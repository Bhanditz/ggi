class Ggi::Classification 
  attr :classification, :names, :taxa

  def initialize
    @taxa, @taxon_names, @taxon_parents, @taxon_children = 
      Ggi::ClassificationImporter.new.import
  end

  def autocomplete(search_term)
    return [] if search_term.size < 3
    search_term.downcase!
    @taxon_names.select { |k, v| k.match /^#{search_term}/i }.
      values.flatten.map{ |id| Taxon.find(id) }
  end

  def find(taxon_id)
    return @taxa[taxon_id]
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    search_term.downcase!
    if @taxon_names[search_term] && taxon_id = @taxon_names[search_term].first
      return Taxon.find(taxon_id)
    end
  end

  def ancestors_of(taxon_id)
    ancestors = []
    search_id = taxon_id
    while parent_id = @taxon_parents[search_id]
      break if parent_id == 0
      parent = Taxon.find(parent_id)
      ancestors.unshift(parent)
      search_id = parent.id
    end
    return ancestors
  end

  def children_of(taxon_id)
    return [] if @taxon_children[taxon_id].nil?
    @taxon_children[taxon_id].map{ |child_id| Taxon.find(child_id) }.
      sort_by{ |t| t.name }
  end

  def siblings_of(taxon_id)
    parent_id = @taxon_parents[taxon_id]
    if parent_id == 0
      parents_children = @taxon_children[0].map{ |child_id| Taxon.find(child_id) }
    else
      parent_taxon = Taxon.find(parent_id)
      parents_children = parent_taxon.children
    end
    parents_children.delete_if{ |t| t.id == taxon_id }
    parents_children.sort_by{ |t| t.name }
  end

end
