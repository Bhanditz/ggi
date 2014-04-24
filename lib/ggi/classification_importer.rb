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
    import_mappings
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
        Ggi::ClassificationImporter.create_measurement_labels(d)
        d[:measurements].delete_if{ |m| m[:label].nil? }
        @taxa[falo_id].merge!(d)
        d[:vernacularNames].each do |v|
          @common_names[v[:vernacularName].capitalize] ||= []
          @common_names[v[:vernacularName].capitalize] << falo_id
        end
      end
    end
  end

  def import_mappings
    mappings_file = File.join(__dir__, '..', '..', 'public', 'falo_mappings.json.gz')
    mappings_json = Zlib::GzipReader.open(mappings_file) { |f| f.read }
    mappings_data = JSON.parse(mappings_json, symbolize_names: true)
    mappings_data.each do |d|
      @taxa[d[:falo_id]][:eol_id] = d[:eol_id]
      @eol_to_falo[d[:eol_id]] = d[:falo_id]
    end
  end

  def import_taxa
    header = nil
    taxon_file = File.join(__dir__, '..', '..', 'public', 'taxon.tab.gz')
    Zlib::GzipReader.open(taxon_file) do |csv|
      csv.each_line do |line|
        # NOTE We don't use quote_char to wrap field content in taxon file.
        #      However, adding | prevents CSV misinterpreting " in content.
        CSV.parse(line, @opts.merge({quote_char: "|"})) do |row|
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

  def self.create_measurement_labels(taxon_hash)
    unless taxon_hash[:measurements].nil?
      taxon_hash[:measurements].each do |measurement|
        measurement[:label] = case measurement[:measurementType]
          when /NumberOfSequencesInGenBank/i
            'GenBank sequences'
          when /NumberRichSpeciesPagesInEOL/i
            'EOL rich pages'
          when /NumberSpecimensInGGBN/i
            'GGBN records'
          when /NumberRecordsInGBIF/i
            'GBIF records'
          when /NumberPublicRecordsInBOLD/i
            'BOLD records'
        end
      end
    end
  end

end
