class Ggi::Classification

  # This is kinda-sorta acting like a singleton to an instance of this class.
  def self.classification
    @classification ||= Ggi::Classification.new
  end

  # NOTE - not the most elegant solution, but this should keep things
  # working until a better one can be devised. For the moment, though,
  def self.method_missing(method_name, *arguments, &block)
    if classification.respond_to?(method_name)
      classification.send(method_name, *arguments, &block)
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    classification.respond_to?(method_name) || super
  end

  # TODO - probably should give this a different name
  def self.taxa
    classification.taxa.values
  end

  def initialize
    @taxa, @taxon_names, @taxon_parents, @taxon_children,
      @common_names = Ggi::ClassificationImporter.new.import
  end

  def taxa
    @taxa
  end

  def find(taxon_id)
    @taxa[taxon_id]
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    if taxon_match = search_hash_for_term(@taxon_names, search_term)
      taxon_match
    elsif common_match = search_hash_for_term(@common_names, search_term)
      common_match
    end
  end

  def roots
    @taxon_children[0].map { |child_id| Ggi::Taxon.find(child_id) }
  end

  def ancestors_of(taxon)
    ancestors = []
    search_id = taxon.id
    while parent_id = @taxon_parents[search_id]
      break if parent_id == 0
      parent = Ggi::Taxon.find(parent_id)
      ancestors.unshift(parent)
      search_id = parent.id
    end
    ancestors
  end

  def children_of(taxon)
    return [] if @taxon_children[taxon.id].nil?
    @taxon_children[taxon.id].map { |child_id| Ggi::Taxon.find(child_id) }.
      sort_by { |t| t.name }
  end

  def siblings_of(taxon)
    parent_id = @taxon_parents[taxon.id]
    if parent_id == 0
      parents_children = roots
    else
      parent_taxon = Ggi::Taxon.find(parent_id)
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

  def autocomplete(search_term)
    Ggi::Autocompleter.search(search_term, [@taxon_names, @common_names])
  end

private

  def search_hash_for_term(hash, term)
    if match = hash.detect { |name, id| name.casecmp(term) == 0 }
      Ggi::Taxon.find(match[1][0])
    end
  end

end
