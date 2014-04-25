class Ggi::ScoreCalculator

  def self.calculate_scores(options = {})
    return unless (options[:taxa] && options[:measurement_type_max_values] &&
      options[:maximum_number_of_scores] && options[:taxon_parents] &&
      options[:taxon_children])
    calculate_measurement_scores(options)
    calculate_family_scores(options)
    calculate_above_family_scores(options)
  end

  def self.calculate_measurement_scores(options = {})
    # this pass is scoring all families
    options[:taxa].each do |id, taxon|
      taxon[:measurements] ||= []
      taxon[:measurements].each do |m|
        m[:score] = Ggi::ScoreCalculator.scale_and_log(
          m[:measurementValue], options[:measurement_type_max_values][m[:measurementType]])
      end
      taxon[:score] = (taxon[:measurements].map{ |m| m[:score] }.inject(:+) || 0) /
        options[:maximum_number_of_scores].to_f
    end
  end

  def self.calculate_family_scores(options = {})
    # normalize all the scores against themselves so we have a 100 out of 100
    max_taxon_score = options[:taxa].collect{ |id, taxon| taxon[:score] }.max
    options[:taxa].each do |id, taxon|
      taxon[:score] = scale_and_log(taxon[:score], max_taxon_score)
    end
  end

  def self.calculate_above_family_scores(options = {})
    # normalize all the scores against themselves so we have a 100 out of 100
    stack = options[:taxa].select{ |id, taxon| taxon[:dwc_record]['taxonRank'] == 'family' }.
      collect{ |id, taxon| options[:taxon_parents][id] }.compact.uniq
    while stack.length > 1
      lookup_id = stack.shift
      this_nodes_parent_id = options[:taxon_parents][lookup_id]
      if children_ids = options[:taxon_children][lookup_id]
        options[:taxa][lookup_id][:score] =
          children_ids.map{ |child_id| options[:taxa][child_id][:score] }.inject(:+) /
          children_ids.length
      end
      unless this_nodes_parent_id == 0 || stack.include?(this_nodes_parent_id)
        stack << this_nodes_parent_id
      end
    end
  end

  # TODO: finalize the scoring algorithms
  # normalizing the ratio to be 0-9, then adding 1 and taking the log base 10 of that
  # this is the same method we use for EOL richness scores
  def self.scale_and_log(value, max_value)
    Math.log(((value / max_value.to_f) * 9) + 1, 10)
  end

end
