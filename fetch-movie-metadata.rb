require 'bundler/setup'
require 'chronic_duration'
require 'date'
require 'htmlentities'
require 'httparty'
require 'json'

def die(*messages)
  messages.each do |message|
    $stderr.puts "fetch-movie-metadata.rb: #{message}"
  end

  exit 1
end

def metadata(to, from = nil)
  if from
    value = @omdb_metadata[from]
  end

  if block_given?
    begin
      value = yield value
    rescue => e
      $stderr.puts "fetch-movie-metadata.rb: error parsing #{to} for #{@title} (#{@year}) (#{e})"
      value = nil
    end
  end

  @metadata[to] = value
end

def omdb(query)
  response = HTTParty.get('http://www.omdbapi.com', query: query)

  unless response.code == 200
    die "got HTTP #{response.code} from server", response.body
  end

  begin
    response_json = JSON.parse(response.body)
  rescue => e
    die "could not parse response JSON (#{e})", response.body
  end

  response_json
end

unless path = ARGV.first
  die 'supply a path to a movie folder as an argument'
end

unless File.basename(path) =~ /(.*) \((\d{4})\)/
  die "#{path.inspect} is not a valid movie folder"
end

@title = $~[1]
@year = $~[2].to_i

response_json = omdb(s: @title.downcase, r: 'json')
results = response_json['Search']

unless results && results.is_a?(Array) && !results.empty?
  die 'no results in the response JSON', response.body
end

match = results.find do |result|
  year = result['Year']
  year && year.to_i == @year
end

unless match && match.is_a?(Hash)
  die 'no match found', response.body
end

@id = match['imdbID']
@omdb_metadata = omdb(i: @id, tomatoes: true, r: 'json')

@metadata = {}

metadata(:actors, 'Actors') { |actors| actors.split(/,\s*/) }
metadata :director, 'Director'
metadata :genre, 'Genre'

metadata :imdb do
  { id: @id }.tap do |metadata|
    rating = @omdb_metadata['imdbRating']
    votes = @omdb_metadata['imdbVotes']

    metadata[:rating] = rating && rating.to_f
    metadata[:votes] = votes && votes.gsub(/[^\d]/, '').to_i
  end
end

metadata :plot, 'Plot'
metadata :poster, 'Poster'
metadata :rating, 'Rated'
metadata(:released, 'Released') { |released|Date.parse(released).iso8601 }

metadata :rotten_tomatoes do
  {}.tap do |metadata|
    meter = @omdb_metadata['tomatoMeter']
    rating = @omdb_metadata['tomatoRating']
    fresh = @omdb_metadata['tomatoFresh']
    rotten = @omdb_metadata['tomatoRotten']
    review = @omdb_metadata['tomatoConsensus']
    user_meter = @omdb_metadata['tomatoUserMeter']
    user_rating = @omdb_metadata['tomatoUserRating']
    user_reviews = @omdb_metadata['tomatoUserReviews']

    metadata[:meter] = meter && meter.to_i
    metadata[:rating] = rating && rating.to_f
    metadata[:fresh] = fresh && fresh.to_i
    metadata[:rotten] = rotten && rotten.to_i
    metadata[:review] = review && HTMLEntities.new.decode(review)
    metadata[:users] = {
      meter: user_meter && user_meter.to_i,
      rating: user_rating && user_rating.to_f,
      reviews: user_reviews && user_reviews.gsub(/[^\d]/, '').to_i
    }
  end
end

metadata(:runtime, 'Runtime') { |runtime| ChronicDuration.parse(runtime) }
metadata :studio, 'Production'
metadata(:title) { @title }
metadata(:type) { 'movie' }
metadata(:writers, 'Writer') { |writers| writers.split(/,\s*/) }
metadata(:year) { @year }

puts JSON.pretty_generate(@metadata)
