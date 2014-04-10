# NOTE (!) ... Try not to touch this file until you need to!  
# You should be focusing on the functionality of the classes in the 
# app before you focus on the web development of those functions.

# ...That said, this framework is here just to alleivate a little of 
# the Compass/Sass-related configuration.

require 'sinatra'
require 'sinatra/assetpack'
require 'haml'
require 'compass'

require_relative 'lib/ggi'
require_relative 'environment'
require_relative 'routes'

configure do
  set :root, settings.root
  set :haml, {:format => :html5}
  set :scss, {:style => :compact, :debug_info => false}
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 
                                              'config', 'compass.rb'))
  set :scss, Compass.sass_engine_options
  
  register Sinatra::AssetPack

  assets do
    serve '/js',     from: 'app/js'        # Default
    serve '/css',    from: 'app/css'       # Default
    serve '/images', from: 'app/images'    # Default

    # The second parameter defines where the compressed version will be served.
    # (Note: that parameter is optional, AssetPack will figure it out.)
    js :app, '/js/app.js', [
      '/js/jquery.js',
      '/js/jquery-ui.js',
      '/js/main.js'
    ]

    css :application, '/css/application.css', [
      '/css/main.css'
    ]

    js_compression  :jsmin    # :jsmin | :yui | :closure | :uglify
    css_compression :sass   # :simple | :sass | :yui | :sqwish
  end

end

