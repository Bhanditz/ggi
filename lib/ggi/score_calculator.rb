class Ggi::ScoreCalculator

  DEFAULT_SCORE = 0

  def self.calculate
    calculator = Ggi::ScoreCalculator.new
    calculator.calculate_scores
  end

  def initialize
    @measurement_type_values = { }
    @measurement_type_values_counts_below = { }
  end

  def calculate_scores
    collect_measurement_statistics
    collect_statistics_for_percentiles
    calculate_and_assign_scores_recursively
  end

private

  # count the occurrences of each value for each measurement type
  # we need to know how many of each value there are to calculate
  # family percentiles later on
  def collect_measurement_statistics
    # calling Taxon (which is a model) makes this class tightly coupled to
    # the model, and thus not really a lib. ...Rather than deal with that,
    # though, I might suggest we don't use models at all and just put
    # everything in the lib.  ...or vice-versa.  We should discuss.
    Ggi::Taxon.all.select { |t| t.family? }.each do |taxon|
      Ggi::ClassificationImporter::MEASUREMENT_URIS_TO_LABELS.each do |uri, label|
        measurement = taxon.measurements.detect { |m| m[:measurementType] == uri }
        value = measurement ? measurement[:measurementValue] : DEFAULT_SCORE
        @measurement_type_values[uri] ||= Hash.new(DEFAULT_SCORE)
        @measurement_type_values[uri][value] += 1
      end
    end
  end

  # efficiently count the number of records, per attribute, which
  # are below a given value. We will use these to calculate percentile
  def collect_statistics_for_percentiles
    @measurement_type_values.each do |type, value_counts|
      @measurement_type_values_counts_below[type] = { }
      sorted_values = value_counts.keys.sort
      sorted_values.each_with_index do |value, index|
        @measurement_type_values_counts_below[type][value] = (index == 0) ? 0 :
          @measurement_type_values_counts_below[type][sorted_values[index - 1]] +
          @measurement_type_values[type][sorted_values[index - 1]]
      end
    end
    @total_number_of_families = Ggi::Taxon.all.select { |t| t.family? }.length.to_f
  end

  # now use the data collected to calculate and assign
  # percentile scores to the tree using a depth-first traversal.
  # Scores for higher taxa are averages of its families' scores
  def calculate_and_assign_scores_recursively(options = {})
    childs_family_scores = [ ]
    children = options[:taxon].nil? ? Classification.roots : options[:taxon].children
    if children
      children.each do |child_taxon|
        if child_taxon.family?
          calculate_score_for_family(child_taxon)
          childs_family_scores << child_taxon.score
        else
          childs_family_scores += calculate_and_assign_scores_recursively(
            options.merge({ family_scores: [ ], taxon: child_taxon }))
        end
      end
      # we started at the root, and now we're back so we're done
      return unless options[:taxon]
      options[:taxon].score = childs_family_scores.empty? ? DEFAULT_SCORE :
        childs_family_scores.inject(:+) / childs_family_scores.length
    end
    childs_family_scores
  end

  def calculate_score_for_family(family)
    family.measurements ||= []
    family.measurements.each do |m|
      m[:score] = percentile(m[:measurementValue], m[:measurementType])
    end
    family.score = (family.measurements.map { |m| m[:score] }.inject(:+) || DEFAULT_SCORE) /
      Ggi::ClassificationImporter::MEASUREMENT_URIS_TO_LABELS.length.to_f
  end

  def percentile(value, type)
    return 0 if ! value || value == DEFAULT_SCORE
    @measurement_type_values_counts_below[type][value] / @total_number_of_families
  end

end
