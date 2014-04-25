helpers do
  def tree_item(taxon, state, current = false)
    html_classes = ['tree__item', "tree__item--#{state.to_s}"]
    html_classes << 'tree__item--selected' if current
    "<li class='#{html_classes.join(' ')}' data-taxon-id='#{taxon.id}' data-children='#{taxon.children.count}'><a href='#{taxon_path(taxon)}'>#{taxon.name}</a></li>"
  end

  def formatted_score(score)
    (score * 100).ceil.to_s + " / 100"
  end

  def taxon_path(taxon)
    "/taxon/#{taxon.id}"
  end

  def eol_page_url(taxon)
    "http://eol.org/pages/#{taxon.eol_id}"
  end

  def eol_dato_url(taxon)
    "http://eol.org/data_objects/#{taxon.image[:dataObjectVersionID]}"
  end
end
