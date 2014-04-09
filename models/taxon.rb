class Taxon

  def self.find(taxon_concept_id)
    taxon_concept_id = taxon_concept_id.to_i
    taxon_json = RestClient.get(Ggi.config.eol_api_url % taxon_concept_id)
    taxon = JSON.parse(taxon_json, symbolize_names: true)
    taxon[:scientificName] ? taxon : nil
  end

end
