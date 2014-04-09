get '/' do
  haml :index
end

get '/search' do
  search_term = params['search_term']
  @node = Classification.search(search_term)
  if @node
    @taxon = Taxon.find(@node.attr(:eol_id))
    haml :taxon
  else
    redirect_to request.referrer
  end
end

get '/autocomplete' do
  search_term = params['search_term']
  candidates = Classification.autocomplete(search_term)

end


