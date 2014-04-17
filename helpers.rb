helpers do
  def show_node(taxon)
    "<li data-taxon-id='#{taxon.id}'><a href='/taxon/#{taxon.id}'>#{taxon.name}</a></li>"
  end
end