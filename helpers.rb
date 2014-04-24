helpers do
  def tree_item(taxon, state, current = false)
    html_classes = ['tree__item', "tree__item--#{state.to_s}"]
    html_classes << 'tree__item--selected' if current
    "<li class='#{html_classes.join(' ')}' data-taxon-id='#{taxon.id}' data-children='#{taxon.children.count}'><a href='#{taxon_path(taxon)}'>#{taxon.name}</a></li>"
  end

  def taxon_path(taxon)
    "/taxon/#{taxon.id}"
  end
end
