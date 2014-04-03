class Ggi

  puts "I'm in Ggi class"

  # TODO

end

puts "I'm loading things..."

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
Dir.glob(File.join(File.dirname(__FILE__), 'models', '**', '*.rb')) do |app|
  puts "Loading #{app}"
  require File.basename(app, '.*')
end

