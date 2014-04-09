def stub_falo
  stub_request(:get, Ggi.config.falo_url).
     to_return(status: 200, body: get_falo_csv)
end

def stub_find_taxon(taxon_concept_id)
  stub_request(:get, Ggi.config.eol_api_url % taxon_concept_id)
    .to_return do |request|
      { status: 200, body: get_taxon_json(request) }
  end
end

private 

def get_falo_csv
  File.read(File.join(__dir__, '..', 'files', 'FALO.csv'))
end

def get_taxon_json(request)
  id = request.uri.to_s.split('/').last
  File.read(File.join(__dir__, '..', 'files', "%s.json" % id))
end
