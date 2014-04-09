get '/' do
  haml :index
end

get '/search' do
  search_term = params['search_term']
  @node = Classification.search(search_term)
  if @node
    @taxon = Taxon.find(@node.attr(:eol_id))
    require 'ruby-debug'; debugger
    render :taxon 
  else
    redirect_to request.referrer
  end
end


