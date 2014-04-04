def get_falo_csv
  File.read(File.join(__dir__, '..', 'files', 'FALO.csv'))
end

def stub_falo
  stub_request(:get, Ggi.config.falo_url).
     to_return(status: 200, body: get_falo_csv)
end
