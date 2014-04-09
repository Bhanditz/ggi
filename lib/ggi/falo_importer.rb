class Ggi::FaloImporter
  HEADERS = %w(Sapk K Sbk Ik SpP P SbP IP PvP SpC C SbC IC SpO O FAMILY).reverse

  def initialize
    @tree = Nokogiri::XML(template)
    @names = {}
  end

  def import
    falo_csv = RestClient.get(Ggi.config.falo_url)
    falo_csv = convert_to_utf8(falo_csv)
    CSV.parse(falo_csv, headers: true).each do |r|
      process_row(r)   
    end
    Ggi::Classification.new(@tree, @names)
  end

  private

  def update_names(name)
    sci_name = name.split(/_/).last.downcase
    @names[sci_name] ? @names[sci_name] << name : @names[sci_name] = [name]  
  end

  def process_row(row)
    node = get_node(row)
    parent_nodes = @tree.xpath("//#{node[:parent]}")
    raise "Homonym problems with %s" % node[:parent] if parent_nodes.size > 1
    if parent_node = parent_nodes.first
      xml_node = Nokogiri::XML::Node.new(node[:name], @tree)
      xml_node['reference'] = row['REFERENCE']
      xml_node['uuid'] = row['UUID']
      xml_node['eol_id'] = row['EolId']
      xml_node['rank'], xml_node['scientific_name'] = node[:name].split(/_+/)
      xml_node.parent = parent_node
    else
      puts "Ignoring %s: No Parent %s" % [node[:name], node[:parent]]
    end
    update_names(node[:name])
  end

  def get_node(row)
    node = nil
    node_found = false
    HEADERS.each do |rank|
      if row[rank] && row[rank].strip != ''
        if node_found
          node[:parent] = row[rank].gsub(/\s+/,'_').gsub(/"/, '')
          break
        else
          node = { rank: rank, name: row[rank].gsub(/\s/,'_').gsub(/"/, '') }
          node_found = true
        end
      end
    end
    node[:parent] ||= 'classification'
    node
  end

  def convert_to_utf8(text)
    text.encode!('UTF-8', 'ISO-8859-1', invalid: :replace, replace: '?')
  end

  def template
    '<?xml version="1.0" encoding="UTF-8"?> <classification> </classification>'
  end
end
