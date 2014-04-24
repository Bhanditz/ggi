require 'sinatra'
require 'sinatra/assetpack'
require 'haml'
require 'compass'
require 'debugger' if Sinatra::Base.development? || Sinatra::Base.test?

require_relative 'lib/ggi'
require_relative 'environment'
require_relative 'routes'
require_relative 'helpers'

Ggi::ClassificationImporter.cache_data

configure do
  set :root, settings.root
  set :haml, format: :html5, layout: :'layouts/application'
  set :scss, style: :compact, debug_info: false
  Compass.add_project_configuration(File.join(Sinatra::Application.root,
                                              'config', 'compass.rb'))
  set :scss, Compass.sass_engine_options

  register Sinatra::AssetPack

  assets do
    serve '/js',     from: 'app/js'
    serve '/css',    from: 'app/css'
    serve '/images', from: 'app/images'

    js :app, '/js/app.js', [
      '/js/jquery.js',
      '/js/jquery.ui.core.js',
      '/js/jquery.ui.widget.js',
      '/js/jquery.ui.position.js',
      '/js/jquery.ui.mouse.js',
      '/js/jquery.ui.menu.js',
      '/js/jquery.ui.autocomplete.js',
      '/js/main.js'
    ]

    css :application, '/css/application.css', [
      '/css/main.css'
    ]

    # TODO Merge jquery css into main once styles are ready
    css :jquery_ui, '/css/jquery.ui.css', [
      '/css/jquery.ui.base.css',
    ]

    js_compression  :jsmin
    css_compression :sass
  end

end

