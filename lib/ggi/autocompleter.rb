class Ggi::Autocompleter

  MAX_LIMIT = 10

  def self.search(term, items)
    ac = Ggi::Autocompleter.new(term)
    items.each { |i| ac.process_item(i) }
    ac.matches
  end
  
  def initialize(term)
    @search_term = term.downcase
    @limit = term.empty? ? 0 : MAX_LIMIT
    @match_hash = {}
  end
  
  def matches
    @match_hash.values
  end
  
  def at_limit?
    @match_hash.length >= @limit
  end

  def process_item(item)
    return if at_limit?
    item.each do |name, ids|
      if name.match(/^#{@search_term}/i)
        add_ids(name, ids)
        return if at_limit?
      end
    end
  end

  def add_ids(name, ids)
    ids.each do |i|
      if !@match_hash.member?(i)
        @match_hash[i] = result(name, i)
      end
      return if at_limit?
    end
  end

  def result(name, i)
    { matched_name: name, taxon: Taxon.find(i) }
  end
end
