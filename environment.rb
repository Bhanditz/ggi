require 'json'

class Ggi

  # TODO

end

puts "** Loading environment."

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
Dir.glob(File.join(File.dirname(__FILE__), 'models', '**', '*.rb')) do |app|
  require File.basename(app, '.*')
end

