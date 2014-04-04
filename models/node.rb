class Node

  PATH = File.join(File.dirname(__FILE__), '../data')

  attr_accessor :json

  def self.get(id)
    Node.new(id)
  end

  def initialize(id)
    # TODO - Use the API instead of reading from a file.
    # TODO - cache this. Shouldn't need to get this more than once a day. Best if we can just clear the cache after, say, 04:00, too.
    # TODO - Custom error classes.
    file = File.join(PATH, "#{id}.json")
    raise "Not Found: #{file}" unless File.exist?(file)
    @json = JSON.parse(File.read(file))
  end

end
