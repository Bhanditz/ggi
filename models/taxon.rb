class Taxon

  def self.find(taxon_concept_id)
    taxon_concept_id = taxon_concept_id.to_i
    taxon_json = RestClient.get(Ggi.config.eol_api_url % taxon_concept_id)
    taxon = JSON.parse(taxon_json, symbolize_names: true)
    taxon[:scientificName] ? taxon : nil
    taxon[:measurements].each do |measurement|
      measurement[:label] = case measurement[:label]
        when /genbank/i
          'GenBank sequences'
        when /EOL/
          'EOL rich pages'
        when /GGBN/
          'GGBN records'
        when /GBIF/
          'GBIF records'
      end
    end
    taxon
  end

end
