class Ggi::Classification 
  attr :classification, :names, :taxa

  def initialize
    @taxa, @taxon_names, @taxon_parents, @taxon_children,
      @common_names = Ggi::ClassificationImporter.new.import
  end

  def autocomplete(search_term)
    return [] if search_term.size < 1
    search_term.downcase!
    matches = [ ]
    Ggi::Classification.add_matches_from_names(
      @taxon_names, search_term, matches)
    Ggi::Classification.add_matches_from_names(
      @common_names, search_term, matches)
    matches
  end

  def find(taxon_id)
    return @taxa[taxon_id]
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    if match = @taxon_names.detect{ |name, taxon_id|
                                      name.casecmp(search_term) == 0 }
      return Taxon.find(match[1].first)
    elsif match = @common_names.detect{ |name, taxon_id|
                                      name.casecmp(search_term) == 0 }
      return Taxon.find(match[1].first)
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
      parents_children =
        @taxon_children[0].map{ |child_id| Taxon.find(child_id) }
    else
      parent_taxon = Taxon.find(parent_id)
      parents_children = parent_taxon.children
    end
    parents_children.delete_if{ |t| t.id == taxon_id }
    parents_children.sort_by{ |t| t.name }
  end

  def self.add_matches_from_names(names, search_term, matches)
    names.select { |k, v| k.match /^#{search_term}/i }.each do |name, taxon_ids|
      taxon_ids.each do |taxon_id|
        unless matches.detect{ |m| m['value'] == taxon_id }
          matches << { 'label' => name, 'value' => taxon_id }
        end
      end
    end
  end

end
