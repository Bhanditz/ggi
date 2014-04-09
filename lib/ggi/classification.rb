class Ggi::Classification 
  attr :classification, :names

  def initialize(tree, names)
    @classification = tree
    @names = names
  end

  def autocomplete(search_term)
    return [] if search_term.size < 3
    @names.select { |k, v| k.match /^#{search_term}/i }.values.flatten
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    node_name = @names.select { |k, v| k == search_term.downcase }.values.first 
    node_name ? @classification.xpath("//%s" % node_name).first : nil
  end
end
