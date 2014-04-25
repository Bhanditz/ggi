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
    @measurement_type_values = { }
    @measurement_uris_to_labels = {
      'http://eol.org/schema/terms/NumberOfSequencesInGenBank' => 'GenBank sequences',
      'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL' => 'EOL rich pages',
      'http://eol.org/schema/terms/NumberSpecimensInGGBN' => 'GGBN records',
      'http://eol.org/schema/terms/NumberRecordsInGBIF' => 'GBIF records',
      'http://eol.org/schema/terms/NumberPublicRecordsInBOLD' => 'BOLD records' }
    # NOTE: We don't use quote_char to wrap field content in taxon file.
    #      However, adding | prevents CSV misinterpreting " in content.
    @csv_parse_options = { col_sep: "\t", quote_char: "|" }
  end

  def import
    return @@imported if @@imported
    import_taxa
    import_mappings
    import_traits
    assign_nested_set_recursively
    score_calculator = Ggi::ScoreCalculator.new(
      taxa: @taxa,
      measurement_type_values: @measurement_type_values,
      maximum_number_of_scores: @measurement_uris_to_labels.length,
      taxon_parents: @taxon_parents,
      taxon_children: @taxon_children)
    score_calculator.calculate_scores
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
        # if we have measurements for taxa that aren't families,
        # then remove them. We only want measurments for families
        if @taxa[falo_id][:dwc_record]['taxonRank'] == 'family'
          verify_measurement_labels(d)
          update_measurement_type_values(d)
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

  def update_measurement_type_values(taxon_hash)
    @measurement_uris_to_labels.each do |uri, label|
      measurement = taxon_hash[:measurements].detect{ |m| m[:measurementType] == uri }
      value = measurement ? measurement[:measurementValue] : 0
      @measurement_type_values[uri] ||= { }
      @measurement_type_values[uri][value] ||= 0
      @measurement_type_values[uri][value] += 1
    end
  end

  def verify_measurement_labels(taxon_hash)
    unless taxon_hash[:measurements].nil?
      # if we get multiple of the same measurement for a taxon,
      # we will take the first and ignore subsequent instances
      used_labels = [ ]
      taxon_hash[:measurements].each do |measurement|
        measurement[:label] = @measurement_uris_to_labels[measurement[:measurementType]]
        if used_labels.include?(measurement[:label])
          measurement[:label] = nil
        end
        used_labels << measurement[:label]
      end
      # delete all measurements without a nice label
      taxon_hash[:measurements].delete_if{ |m| m[:label].nil? }
    end
  end

  def assign_nested_set_recursively(options = {})
    options[:current_value] ||= 0
    options[:current_parent_id] ||= 0
    if @taxon_children[options[:current_parent_id]]
      @taxon_children[options[:current_parent_id]].each do |child_taxon_id|
        @taxa[child_taxon_id][:left_value] = options[:current_value]
        options[:current_value] += 1
        options[:current_value] = assign_nested_set_recursively(options.merge({
          current_value: options[:current_value],
          current_parent_id: child_taxon_id,
          }))
        @taxa[child_taxon_id][:right_value] = options[:current_value]
        options[:current_value] += 1
      end
    end
    return options[:current_value]
  end

end
