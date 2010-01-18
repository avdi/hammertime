require 'lib/hammertime'

$broken = true

def faulty_method
  raise "Oh no!" if $broken
end

3.times do |n|
  puts "Attempt (#{n+1}/3)"
  begin
    faulty_method
    puts "No error raised"
  rescue => error
    puts "Error raised: #{error.inspect}"
  end
end


