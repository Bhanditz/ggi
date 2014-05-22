namespace 'ggi' do

  namespace 'downloads' do

    desc 'Create XSLX download file '\
         '`rake "ggi:downloads:create[2.5, 2014.05.20, public/ggi.xlsx]"`.'
    task :create, :version, :updated, :filepath do |t, args|
      Ggi::ClassificationImporter.cache_data
      Ggi::AllFamiliesDownload.create(args)
    end

  end

end
