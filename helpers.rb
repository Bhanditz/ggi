helpers do
  def tree_item(taxon, state, current = false)
    html_classes = ['tree__item', "tree__item--#{state.to_s}"]
    html_classes << 'tree__item--selected' if current
    "<li class='#{html_classes.join(' ')}' data-taxon-id='#{taxon.id}' data-children='#{taxon.children.count}'><a href='#{taxon_path(taxon)}'>#{taxon.name}</a></li>"
  end

  def formatted_score(score)
    (score * 100).ceil.to_s
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

  def image_attribution(image)
    agents = {}
    if image[:agents].kind_of?(Array)
      agents = image[:agents].map do |a|
        { a[:role] => a[:full_name] }
      end.compact.reduce({}, :merge)
      provider = agents.delete("provider")
    end
    owner = image[:rightsHolder] || agents[:photographer]
    owner = agents.first[1] if owner.nil? && !agents.empty?
    owner = "By #{owner}" if owner
    provider = "via #{provider}" if provider
    [owner, provider].compact.join(' ').capitalize;
  end

  def license(license)
    uri = URI(license)
    return license unless uri.scheme == 'http'
    path = uri.path.to_s.gsub('.html', '').split('/').reject{ |p| p.empty? }
    html_class = path.join('--').gsub(/[.]/, '-')
    title = path.reject{|p| p == 'licenses'}.join(' ').upcase
    case uri.host
    when 'creativecommons.org'
      type = path[1].gsub('-', '_')
      label = Ggi::Svg.send(type) if type && Ggi::Svg.respond_to?(type)
      title = "Creative Commons #{title}"
    when 'www.gnu.org'
      label = title = "GNU #{title}"
    end
    label ||= title
    "<a rel='license' title='Image licensed under #{title}' class='#{html_class}' href='#{uri.to_s}'>#{label}</a>"
  end
end
