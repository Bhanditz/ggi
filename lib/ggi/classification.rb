class Ggi::Classification 
  attr :classification, :names

  def initialize(tree, names)
    @classification = tree
    @names = names
  end

  def autocomplete(search)
    return [] if search.size < 3
    @names.select { |k, v| k.match /^#{search}/i }.values.flatten
  end

end
