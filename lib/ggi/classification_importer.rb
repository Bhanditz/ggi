class Ggi::ClassificationImporter

  def initialize
    @taxon_parents = { }
    @taxon_children = { }
    @taxon_names = { }
    @taxa = { }
    @eol_to_falo = { }
    @data = { }
    @opts = { col_sep: "\t" }
  end
  
  def import
    import_taxa
    import_falo_classification
    import_traits
    [@taxa, @taxon_names, @taxon_parents, @taxon_children]
  end
 
  private

  def import_traits
    traits_file = File.join(__dir__, '..', '..', 'public', 'falo_data.json.gz') 
    traits_json = Zlib::GzipReader.open(traits_file) { |f| f.read }
    traits_data = JSON.parse(traits_json, symbolize_names: true)
    traits_data.each do |d|
      next unless d.is_a?(Hash)
      if falo_id = @eol_to_falo[d[:identifier]]
        @taxa[falo_id].merge!(d)
      end
    end
  end

  def import_falo_classification
    falo_file = File.join(__dir__, '..', '..', 'public', 'falo_mapping.tab.gz')
    Zlib::GzipReader.open(falo_file) do |csv|
      csv.each_line do |line|
        CSV.parse(line, @opts) do |row|
          @taxa[row[0]][:eol_id] = row[1]
          @eol_to_falo[row[1].to_i] = row[0];
        end
      end
    end
  end

  def import_taxa
    header = nil
    taxon_file = File.join(__dir__, '..', '..', 'public', 'taxon.tab.gz')
    Zlib::GzipReader.open(taxon_file) do |csv|
      csv.each_line do |line|
        CSV.parse(line, @opts) do |row|
          if header.nil?
            header = row
            next
          end
          handle_taxon_row(row, header)
        end
      end
    end
  end

  def handle_taxon_row(row, header)
    @taxa[row[header.index('taxonID')]] = 
      { id: row[header.index('taxonID')] }
    @taxa[row[header.index('taxonID')]][:dwc_record] = 
      header.zip(row).to_h
    @taxon_parents[row[header.index('taxonID')]] = 
      row[header.index('parentNameUsageID')]
    @taxon_children[row[header.index('parentNameUsageID')]] ||= [ ]
    @taxon_children[row[header.index('parentNameUsageID')]] << 
      row[header.index('taxonID')]
    @taxon_names[row[header.index('scientificName')].downcase] ||= [ ]
    @taxon_names[row[header.index('scientificName')].downcase] << 
      row[header.index('taxonID')]
  end
end
