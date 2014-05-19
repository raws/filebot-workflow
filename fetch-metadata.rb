unless path = ARGV.first.dup
  $stderr.puts 'fetch-metadata.rb: supply a path to a media folder as an argument'
  exit 1
end

path.strip!
root = File.dirname(__FILE__)

if path =~ %r{\A/volume1/movies}
  args = ['/usr/bin/env', 'ruby', File.join(root, 'fetch-movie-metadata.rb')] + ARGV
  exec *args
end
