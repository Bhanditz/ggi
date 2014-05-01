class Ggi::NestedSetBuilder
  class << self

    def assign_nested_set_recursively(options = {})
      options[:value] ||= 0
      children = options[:taxon].nil? ? Classification.roots : options[:taxon].children
      if children
        children.each do |child_taxon|
          child_taxon.left_value = options[:value]
          options[:value] += 1
          options[:value] = assign_nested_set_recursively(options.merge({
            value: options[:value],
            taxon: child_taxon
          }))
          child_taxon.right_value = options[:value]
          options[:value] += 1
        end
      end
      return options[:value]
    end

    alias_method :begin, :assign_nested_set_recursively

  end
end
