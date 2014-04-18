get '/' do
  @taxon ||= Taxon.find_by_name('Eukaryota')
  haml :'layouts/taxonomy' do
    haml :taxon, layout: false
  end
end

get '/search' do
  search_term = params['search_term']
  @node = Taxon.find(search_term) || Taxon.find_by_name(search_term)
  if @node
    redirect "/taxon/%s" % @node.id
  else
    redirect request.referrer
  end
end

get '/autocomplete' do
  opts = { search_term: params[:search_term], callback: params[:callback] }
  taxa = Taxon.autocomplete(opts[:search_term])[0..10]
  cache_control :public, max_age: (60 * 60 * 24)
  content_type :json
  taxa.to_json
end

get '/taxon/:id' do
  @taxon ||= Taxon.find(params[:id])
  if @taxon
    haml :'layouts/taxonomy' do
      haml :taxon, layout: false
    end
  else
    status 404
    "404 not found"
  end
end

get '/api/taxonomy/:id' do
  @taxon ||= Taxon.find(params[:id])
  if @taxon
    haml :_taxonomy, layout: false, locals: { taxon: @taxon }
  end
end

get '/api/details/:id' do
  @taxon ||= Taxon.find(params[:id])
  if @taxon
    haml :taxon, layout: false
  end
end

get '/about' do
  haml :about
end

get '/help' do
  haml :help
end

get '/download' do
  haml :download
end
