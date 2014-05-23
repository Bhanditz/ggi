namespace 'ggi' do

  namespace 'downloads' do

    desc 'Create XSLX download file '\
         '`rake "ggi:downloads:create[2014.05.20, 2.5, public/ggi.xlsx]"`.'
    task :create, :updated, :version, :filepath do |t, args|
      Ggi::ClassificationImporter.cache_data
      Ggi::AllFamiliesDownload.create(args)
    end

  end

end
