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
    redirect request.referrer
  end
end

get '/autocomplete' do
  opts = { search_term: params[:search_term], callback: params[:callback] }
  names = Classification.autocomplete(opts[:search_term])[0..10].to_json

  content_type 'application/json', charset: 'utf-8'
  "%s(%s)" % [opts[:callback], names]
end


