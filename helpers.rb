helpers do

  def tree_item(taxon, state, current = false)
    html_classes = ['tree__item', "tree__item--#{state.to_s}"]
    html_classes << 'tree__item--selected' if current
    if (qualifier = score_qualifier(formatted_score(taxon.score)))
      html_classes << "tree__item--#{qualifier}"
      icon = score_icon(qualifier)
    end
    "<li class='#{html_classes.compact.join(' ')}' data-taxon-id='#{taxon.id}' "\
      "data-children='#{taxon.children.count}'>#{icon}<a href='#{taxon_path(taxon)}'>"\
      "#{taxon.name}</a></li>"
  end

  def formatted_score(score)
    (score * 100).ceil.to_s
  end

  def score_qualifier(score_formatted)
    return nil if score_formatted.to_s.empty?
    return 'poor' if score_formatted.to_i < 51
    return 'good' if score_formatted.to_i > 80
    return 'average' if score_formatted.to_i.between?(51, 80)
    nil
  end

  def score_icon(score_qualifier)
    Ggi::Svg.send(score_qualifier) rescue nil
  end

  def taxon_path(taxon)
    "/taxon/#{taxon.id}"
  end

  def eol_page_url(taxon)
    "http://eol.org/pages/#{taxon.eol_id}"
  end

  def eol_dato_url(taxon)
    "http://eol.org/data_objects/#{taxon.image[:dataObjectVersionID]}"
  end

  # TODO - generalize this somehow with Ggi::Uri
  def measurement_source
    { 'http://eol.org/schema/terms/NumberOfSequencesInGenBank' =>
        '<a href="https://www.ncbi.nlm.nih.gov/genbank">GenBank</a> sequences '\
        '<a href="http://eol.org/schema/terms/NumberOfSequencesInGenBank">?</a>',
      'http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL' =>
        '<a href="http://eol.org"><abbr title="Encyclopedia of Life">EOL</abbr>'\
        '</a> rich pages <a '\
        'href="http://eol.org/schema/terms/NumberRichSpeciesPagesInEOL">?</a>',
      'http://eol.org/schema/terms/NumberSpecimensInGGBN' =>
        '<a href="http://ggbn.org"><abbr title="Global Genome Biodiversity '\
        'Network">GGBN</abbr></a> records '\
        '<a href="http://eol.org/schema/terms/NumberSpecimensInGGBN">?</a>',
      'http://eol.org/schema/terms/NumberRecordsInGBIF' =>
        '<a href="http://gbif.org"><abbr title="Global Biodiversity Information'\
        'Facility">GBIF</abbr></a> records '\
        '<a href="http://eol.org/schema/terms/NumberRecordsInGBIF">?</a>',
      'http://eol.org/schema/terms/NumberPublicRecordsInBOLD' =>
        '<a href="http://boldsystems.org"><abbr title="Barcode of Life Data">'\
        'BOLD</abbr></a> records '\
        '<a href="http://eol.org/schema/terms/NumberPublicRecordsInBOLD">?</a>',
      'http://eol.org/schema/terms/NumberReferencesInBHL' =>
        '<a href="http://biodiversitylibrary.org"><abbr title="Biodiversity '\
        'Heritage Library">BHL</abbr></a> pages <a '\
        'href="http://eol.org/schema/terms/NumberReferencesInBHL">?</a>' }
  end

  def image_attribution(image)
    agents_by_role = {}
    if image[:agents].kind_of?(Array)
      agents_by_role = image[:agents].select{|a| !a[:role].nil?}.map do |a|
        { a[:role].to_sym => a[:full_name] }
      end.compact.reduce({}, :merge)
      provider = agents_by_role.delete(:provider)
      photographer = agents_by_role.delete(:photographer)
      other = agents_by_role.values.first
    end
    owner = image[:rightsHolder] || photographer || other
    owner = "by #{owner}" if owner
    provider = "via #{provider}" if provider
    attribution = [owner, provider].compact.join(' ')
    attribution[0] = attribution[0].capitalize unless attribution.empty?
    attribution
  end

  def license(license)
    uri = URI(license)
    return license unless uri.scheme == 'http'
    path = uri.path.to_s.gsub('.html', '').split('/').reject { |p| p.empty? }
    html_class = path.join('--').gsub(/\./, '-')
    title = path.reject {|p| p == 'licenses'}.join(' ').upcase
    case uri.host
    when 'creativecommons.org'
      type = path[1].gsub('-', '_')
      label = Ggi::Svg.send(type) if type && Ggi::Svg.respond_to?(type)
      title = "Creative Commons #{title}"
    when 'www.gnu.org'
      label = title = "GNU #{title}"
    end
    label ||= title
    "<a rel='license' title='Image licensed under #{title}' "\
      "class='#{html_class}' href='#{uri.to_s}'>#{label}</a>"
  end

end
