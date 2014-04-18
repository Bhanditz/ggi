class Ggi::ClassificationImporter

  @@imported = nil

  def self.cache_data
    Ggi::ClassificationImporter.new.import
  end

  def initialize
    @taxon_parents = { }
    @taxon_children = { }
    @taxon_names = { }
    @taxa = { }
    @common_names = { }
    @eol_to_falo = { }
    @data = { }
    @opts = { col_sep: "\t" }
  end
  
  def import
    return @@imported if @@imported
    import_taxa
    import_falo_classification
    import_traits
    @@imported = [ @taxa, @taxon_names, @taxon_parents,
                   @taxon_children, @common_names ]
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
        d[:vernacularNames].each do |v|
          @common_names[v[:vernacularName].capitalize] ||= []
          @common_names[v[:vernacularName].capitalize] << falo_id
        end
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
    # This is what .zip does:
    # header = [ col1, col2 ]
    # row = [ row1ValueA, row1ValueB ]
    # header.zip(row).to_h => { col1 => row1ValueA, col2 => row1ValueB }
    row = header.zip(row).to_h
    parent_id = row['parentNameUsageID']
    parent_id = 0 if parent_id.to_s.strip.empty?
    @taxa[row['taxonID']] = { id: row['taxonID'] }
    @taxa[row['taxonID']][:dwc_record] = row
    @taxon_parents[row['taxonID']] = parent_id
    @taxon_children[parent_id] ||= [ ]
    @taxon_children[parent_id] << row['taxonID']
    @taxon_names[row['scientificName'].capitalize] ||= [ ]
    @taxon_names[row['scientificName'].capitalize] <<  row['taxonID']
  end
end
