helpers do
  def show_node(taxon, state)
    "<li class='#{state.to_s}' data-taxon-id='#{taxon.id}' data-children='#{taxon.children.count}'><a href='/taxon/#{taxon.id}'>#{taxon.name}</a></li>"
  end
end
