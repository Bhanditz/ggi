class Ggi::Autocompleter

  attr_reader :matches
  
  MAX_LIMIT = 10

  def self.search(term, items)
    ac = Ggi::Autocompleter.new(term)
    items.each { |i| ac.process_item(i) }
    ac.matches
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
  
  private
  
  def initialize(term)
    @search_term = term.downcase
    @limit = term.empty? ? 0 : MAX_LIMIT
    @matches = {}
  end
  
  def at_limit?
    @matches.length >= @limit
  end

  def add_ids(name, ids)
    ids.each do |i|
      if !@matches.member?(i)
        @matches[i] = name
      end
      return if at_limit?
    end
  end
end
