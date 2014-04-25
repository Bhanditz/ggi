class Ggi::ScoreCalculator

  def initialize(options = {})
    @taxa = options[:taxa]
    @measurement_type_values = options[:measurement_type_values]
    @maximum_number_of_scores = options[:maximum_number_of_scores]
    @taxon_parents = options[:taxon_parents]
    @taxon_children = options[:taxon_children]
    @measurement_type_values_counts_below = { }
    initial_calculations
  end

  def initial_calculations
    # efficiently count the number of records, per attribute, which
    # are below a given value. We will use these to calculate percentile
    @measurement_type_values.each do |type, value_counts|
      @measurement_type_values_counts_below[type] = { }
      sorted_values = value_counts.keys.sort
      sorted_values.each_with_index do |value, index|
        @measurement_type_values_counts_below[type][value] =
          (index == 0) ? 0 : @measurement_type_values_counts_below[type][sorted_values[index - 1]] +
            @measurement_type_values[type][sorted_values[index - 1]]
      end
    end
    # count the total number of records which have a value
    # for a given attribute. If we assume that all records with
    # unknown values actually have a value of 0, then this should essentially
    # equal the number of families
    @measurement_type_totals = Hash[ @measurement_type_values.map{ |type, values|
      [ type, values.map{ |k, v| v }.inject(:+).to_f ] } ]
  end

  def calculate_scores
    calculate_measurement_scores
    # calculate_family_scores
    calculate_above_family_scores
  end

  def calculate_measurement_scores
    @taxa.each do |id, taxon|
      taxon[:measurements] ||= []
      taxon[:measurements].each do |m|
        m[:score] = percentile(m[:measurementValue], m[:measurementType])
      end
      taxon[:score] = (taxon[:measurements].map{ |m| m[:score] }.inject(:+) || 0) /
        @maximum_number_of_scores.to_f
    end
  end

  # def calculate_family_scores
  #   # normalize all the scores against themselves so we have a 100 out of 100
  #   max_taxon_score = @taxa.collect{ |id, taxon| taxon[:score] }.max
  #   @taxa.each do |id, taxon|
  #     taxon[:score] = scale_and_log(taxon[:score], max_taxon_score)
  #   end
  # end

  def calculate_above_family_scores
    stack = @taxa.select{ |id, taxon| taxon[:dwc_record]['taxonRank'] == 'family' }.
      collect{ |id, taxon| @taxon_parents[id] }.compact.uniq
    while stack.length > 1
      lookup_id = stack.shift
      this_nodes_parent_id = @taxon_parents[lookup_id]
      if children_ids = @taxon_children[lookup_id]
        @taxa[lookup_id][:score] =
          children_ids.map{ |child_id| @taxa[child_id][:score] }.inject(:+) /
          children_ids.length
      end
      unless this_nodes_parent_id == 0 || stack.include?(this_nodes_parent_id)
        stack << this_nodes_parent_id
      end
    end
  end

  # # TODO: finalize the scoring algorithms
  # # normalizing the ratio to be 0-9, then adding 1 and taking the log base 10 of that
  # # this is the same method we use for EOL richness scores
  # def scale_and_log(value, max_value)
  #   Math.log(((value / max_value.to_f) * 9) + 1, 10)
  # end

  def percentile(value, type)
    return 0 if ! value || value == 0
    @measurement_type_values_counts_below[type][value] /
      @measurement_type_totals[type]
  end

end
