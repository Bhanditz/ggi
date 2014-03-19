# NOTE (!) ... Try not to touch this file until you need to!  You should be focusing on the functionality of the classes in the app before you focus on the
# web development of those functions.

# ...That said, this framework is here just to alleivate a little of the Compass/Sass-related configuration.

require 'compass'
require 'sinatra'
require 'haml'

require_relative 'lib/ggi'

configure do
  set :haml, {:format => :html5}
  set :scss, {:style => :compact, :debug_info => false}
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :"stylesheets/#{params[:name]}", Compass.sass_engine_options
end

get '/' do
  haml :index
end

