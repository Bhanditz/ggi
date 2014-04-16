class Ggi::Classification 
  attr :classification, :names

  def initialize
    import
  end

  def autocomplete(search_term)
    return [] if search_term.size < 3
    search_term.downcase!
    @taxon_names.select { |k, v| k.match /^#{search_term}/i }.values.flatten.map{ |id| @taxa[id] }
  end

  def find(taxon_id)
    return @taxa[taxon_id]
  end

  def search(search_term)
    return nil if search_term.to_s == ''
    search_term.downcase!
    if @taxon_names[search_term] && taxon_id = @taxon_names[search_term].first
      return @taxa[taxon_id]
    end
  end

  def ancestors_of(taxon_id)
    ancestors = []
    search_id = taxon_id
    while parent_id = @taxon_parents[search_id]
      parent = @taxa[parent_id]
      ancestors.unshift(parent)
      search_id = parent.id
    end
    return ancestors
  end

  def children_of(taxon_id)
    return [] if @taxon_children[taxon_id].nil?
    @taxon_children[taxon_id].map{ |child_id| @taxa[child_id] }.sort_by{ |t| t.name }
  end

  def import
    @taxon_parents = { }
    @taxon_children = { }
    @taxon_names = { }
    @taxa = { }
    @eol_to_falo = { }
    @data = { }
    opts = { col_sep: "\t" }
    header = nil
    Zlib::GzipReader.open(File.dirname(__FILE__) + "/../../public/taxon.tab.gz") do |csv|
      csv.each_line do |line|
        CSV.parse(line, opts) do |row|
          if header.nil?
            header = row
            next
          end
          @taxa[row[header.index('taxonID')]] = { id: row[header.index('taxonID')] }
          @taxa[row[header.index('taxonID')]][:dwc_record] = header.zip(row).to_h
          @taxon_parents[row[header.index('taxonID')]] = row[header.index('parentNameUsageID')]
          @taxon_children[row[header.index('parentNameUsageID')]] ||= [ ]
          @taxon_children[row[header.index('parentNameUsageID')]] << row[header.index('taxonID')]
          @taxon_names[row[header.index('scientificName')].downcase] ||= [ ]
          @taxon_names[row[header.index('scientificName')].downcase] << row[header.index('taxonID')]
        end
      end
    end
    Zlib::GzipReader.open(File.dirname(__FILE__) + "/../../public/falo_mapping.tab.gz") do |csv|
      csv.each_line do |line|
        CSV.parse(line, opts) do |row|
          @taxa[row[0]][:eol_id] = row[1]
          @eol_to_falo[row[1].to_i] = row[0];
        end
      end
    end
    all_data = JSON.parse(Zlib::GzipReader.open(File.dirname(__FILE__) + "/../../public/falo_data.json.gz") { |f| f.read }, symbolize_names: true)
    all_data.each do |d|
      next unless d.is_a?(Hash)
      if falo_id = @eol_to_falo[d[:identifier]]
        @taxa[falo_id].merge!(d)
      end
    end
    @taxa.each{ |taxon_id, taxon| @taxa[taxon_id] = Taxon.new(taxon) }
  end
end
