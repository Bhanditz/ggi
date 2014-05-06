class Ggi::Classification

  MAX_AUTOCOMPLETE_RESULTS = 10

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

  def taxa
    return @taxa
  end

  def find(taxon_id)
    return @taxa[taxon_id]
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    if match = @taxon_names.detect { |name, taxon_id|
                                      name.casecmp(search_term) == 0 }
      return Taxon.find(match[1].first)
    elsif match = @common_names.detect { |name, taxon_id|
                                      name.casecmp(search_term) == 0 }
      return Taxon.find(match[1].first)
    end
  end

  def roots
    @taxon_children[0].map { |child_id| Taxon.find(child_id) }
  end

  def ancestors_of(taxon)
    ancestors = []
    search_id = taxon.id
    while parent_id = @taxon_parents[search_id]
      break if parent_id == 0
      parent = Taxon.find(parent_id)
      ancestors.unshift(parent)
      search_id = parent.id
    end
    return ancestors
  end

  def children_of(taxon)
    return [] if @taxon_children[taxon.id].nil?
    @taxon_children[taxon.id].map { |child_id| Taxon.find(child_id) }.
      sort_by { |t| t.name }
  end

  def siblings_of(taxon)
    parent_id = @taxon_parents[taxon.id]
    if parent_id == 0
      parents_children = roots
    else
      parent_taxon = Taxon.find(parent_id)
      parents_children = parent_taxon.children
    end
    parents_children.delete_if { |t| t.id == taxon.id }
    parents_children.sort_by { |t| t.name }
  end

  def families_within(taxon)
    @taxa.select { |id, t|
      t.left_value.between?(taxon.left_value, taxon.right_value) && t.family? }.values
  end

  def number_of_families_under(taxon)
    families_within(taxon).length
  end

  def self.add_matches_from_names(names, search_term, matches)
    return if matches.length >= self::MAX_AUTOCOMPLETE_RESULTS
    names.select { |k, v| k.match /^#{search_term}/i }.each do |name, taxon_ids|
      taxon_ids.each do |taxon_id|
        unless matches.detect { |m| m[:taxon].id == taxon_id }
          matches << { matched_name: name, taxon: Taxon.find(taxon_id) }
          return if matches.length >= self::MAX_AUTOCOMPLETE_RESULTS
        end
      end
    end
  end

end
