class Node

  # TODO - Eventually this will only be used by specs. Figure that out later.
  PATH = File.join(File.dirname(__FILE__), '../spec/files')

  attr_accessor :json

  def self.get(id)
    Node.new(id)
  end

  def initialize(id)
    # TODO - Use the API instead of reading from a file.
    file = File.join(PATH, "#{id}.json")
    raise "Not Found: #{file}" unless File.exist?(file)
    @json = JSON.parse(File.read(file))
  end

end
