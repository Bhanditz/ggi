get '/' do
  haml :'layouts/taxonomy' do
    haml :index, layout: false
  end
end

get '/search' do
  search_term = params['search_term']
  @node = Classification.search(search_term)
  if @node
    redirect "/taxon/%s" % @node.attr(:scientific_name).downcase
  else
    redirect request.referrer
  end
end

get '/autocomplete' do
  opts = { search_term: params[:search_term], callback: params[:callback] }
  names = Classification.autocomplete(opts[:search_term])[0..10]
  names = names.map { |n| n.split('_').last }.to_json
  content_type 'application/json', charset: 'utf-8'
  "%s(%s)" % [opts[:callback], names]
end

get '/taxon/:scientific_name' do
  @node ||= Classification.search(params[:scientific_name])
  if @node
    @taxon = Taxon.find(@node.attr(:eol_id))
    haml :'layouts/taxonomy' do
      haml :taxon, layout: false
    end
  else
    redirect request.referrer
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


