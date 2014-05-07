get '/' do
  @taxon ||= Ggi::Taxon.find_by_name('Eukaryota')
  haml :'layouts/browser' do
    haml :taxon, layout: false
  end
end

get '/search' do
  search_term = params['search_term']
  @node = Ggi::Taxon.find(search_term) || Ggi::Taxon.find_by_name(search_term)
  if @node
    redirect taxon_path(@node)
  else
    status 404
    "404 not found"
  end
end

get '/autocomplete' do
  autocomplete_results = Ggi::Taxon.autocomplete(params[:search_term])
  cache_control :public, max_age: (60 * 60 * 24)
  content_type :json
  autocomplete_results.map do |r|
    { id: r[:taxon].id,
      value: r[:taxon].name,
      label: haml(:_taxon_autocomplete, layout: false, locals:
        { taxon: r[:taxon], matched_name: r[:matched_name] })
    }
  end.to_json
end

get '/taxon/:id' do
  @taxon ||= Ggi::Taxon.find(params[:id])
  if @taxon
    haml :'layouts/browser' do
      haml :taxon, layout: false
    end
  else
    status 404
    "404 not found"
  end
end

get '/api/taxonomy/:id' do
  @taxon ||= Ggi::Taxon.find(params[:id])
  if @taxon
    haml :_taxonomy, layout: false, locals: { taxon: @taxon }
  end
end

get '/api/details/:id' do
  @taxon ||= Ggi::Taxon.find(params[:id])
  if @taxon
    haml :taxon, layout: false
  end
end

get '/about' do
  haml :'layouts/basic' do
    haml :about, layout: false
  end
end

get '/help' do
  haml :'layouts/basic' do
    haml :help, layout: false
  end
end

get '/download' do
  haml :'layouts/basic' do
    haml :download, layout: false
  end
end
