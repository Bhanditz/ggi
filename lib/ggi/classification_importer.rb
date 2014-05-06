class Ggi::ClassificationImporter

  @@imported = nil

  MEASUREMENT_URIS_TO_LABELS = {
    'http://eol.org/schema/terms/NumberOfSequencesInGenBank' => 'GenBank sequences',
    'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL' => 'EOL rich pages',
    'http://eol.org/schema/terms/NumberSpecimensInGGBN' => 'GGBN records',
    'http://eol.org/schema/terms/NumberRecordsInGBIF' => 'GBIF records',
    'http://eol.org/schema/terms/NumberPublicRecordsInBOLD' => 'BOLD records',
    'http://eol.org/schema/terms/NumberReferencesInBHL' => 'BHL pages' }

  def self.cache_data
    Ggi::ClassificationImporter.new.import
    Ggi::NestedSetBuilder.build
    Ggi::ScoreCalculator.calculate
  end

  def initialize
    @taxon_parents = { }
    @taxon_children = { }
    @taxon_names = { }
    @taxa = { }
    @common_names = { }
    @eol_to_falo = { }
    # NOTE: We don't use quote_char to wrap field content in taxon file.
    #      However, adding | prevents CSV misinterpreting " in content.
    @csv_parse_options = { col_sep: "\t", quote_char: "|" }
  end

  def import
    return @@imported if @@imported
    import_taxa
    import_mappings
    import_traits
    convert_taxa_to_objects
    @@imported = [ @taxa, @taxon_names, @taxon_parents,
                   @taxon_children, @common_names ]
  end

  private

  def import_taxa
    header = nil
    taxon_file = File.join(__dir__, '..', '..', 'public', 'taxon.tab.gz')
    Zlib::GzipReader.open(taxon_file) do |csv|
      csv.each_line do |line|
        CSV.parse(line, @csv_parse_options) do |row|
          if header.nil?
            header = row
            next
          end
          handle_taxon_row(row, header)
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

  def import_traits
    traits_file = File.join(__dir__, '..', '..', 'public', 'falo_data.json.gz')
    traits_json = Zlib::GzipReader.open(traits_file) { |f| f.read }
    traits_data = JSON.parse(traits_json, symbolize_names: true)
    traits_data.each do |d|
      next unless d.is_a?(Hash)
      if falo_id = @eol_to_falo[d[:identifier]]
        # if we have measurements for taxa that aren't families,
        # then remove them. We only want measurments for families
        if @taxa[falo_id][:dwc_record]['taxonRank'] == 'family'
          verify_measurement_labels(d)
        else
          d[:measurements] = [ ]
        end
        @taxa[falo_id].merge!(d)
        d[:vernacularNames].each do |v|
          @common_names[v[:vernacularName].capitalize] ||= []
          @common_names[v[:vernacularName].capitalize] << falo_id
        end
      end
    end
  end

  def convert_taxa_to_objects
    @taxa.each do |taxon_id, taxon|
      @taxa[taxon_id] = Taxon.new(taxon)
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

  def verify_measurement_labels(taxon_hash)
    unless taxon_hash[:measurements].nil?
      # if we get multiple of the same measurement for a taxon,
      # we will take the first and ignore subsequent instances
      used_labels = [ ]
      taxon_hash[:measurements].each do |measurement|
        measurement[:label] =
          Ggi::ClassificationImporter::MEASUREMENT_URIS_TO_LABELS[measurement[:measurementType]]
        if used_labels.include?(measurement[:label])
          measurement[:label] = nil
        end
        used_labels << measurement[:label]
      end
      # delete all measurements without a nice label
      taxon_hash[:measurements].delete_if { |m| m[:label].nil? }
    end
  end

end
