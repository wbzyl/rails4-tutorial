# -*- coding: utf-8 -*-

# Stara wersja jest tutaj:
#   https://gist.github.com/1295716
# Nowa wersja:
#   https://gist.github.com/1295817

# Zamiast Google image graph api
# użyć biblioteki JavaScript [dygraphs](http://dygraphs.com/)

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

require 'geo-distance'

require 'pp'

# zobacz https://github.com/winston/google_visualr
# require 'google_visualr'

# http://stackoverflow.com/questions/798710/how-to-turn-a-ruby-hash-into-http-params

class Hash
  def to_params
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      elsif v.is_a?(Array)
        stack << [k,Hash.from_array(v)]
      else
        params << "#{k}=#{v}&"
      end
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{v}&"
        end
      end
    end

    params.chop!
    params
  end

  def self.from_array(array = [])
    h = Hash.new
    array.size.times do |t|
      h[t] = array[t]
    end
    h
  end

end

# https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE

class Elevation

  ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json'

  attr_accessor :locations, :array, :path, :distance, :highest, :lowest, :uri

  def initialize(opts={})
    @options = {
      :locations => "49.2710,19.9813|49.2324,19.9817",
      :samples => 11,
      :sensor => false
    }.merge!(opts)
    @locations = @options.delete(:locations)
    @options[:path] = @locations

    set_path_and_array_and_uri

    lon1 = @path[0]['location']['lng']
    lat1 = @path[0]['location']['lat']
    lon2 = @path[1]['location']['lng']
    lat2 = @path[1]['location']['lat']
    @distance = GeoDistance::Haversine.geo_distance(lat1,lon1,lat2,lon2).kms * (@options[:samples]-1)

    @highest = @array.max
    @lowest  = @array.min
  end

  # http://www.damnhandy.com/2011/01/18/url-vs-uri-vs-urn-the-confusion-continues/

  def self.elevation_chart_uri(elevation, opts={})
    chart_base_url = 'http://chart.apis.google.com/chart'
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html

    width = (elevation.distance * (200/(1.5 * 2))).to_i  # 1.5 = 1500 m
    chs = "#{width}x#{200}"

    chart_args = {
      :cht   => "lc",
      :chs   => chs,
      # optional margins
      :chma  => "0,0,0,0|80,20", # nie działa -- dlaczego?
      # optional args
      :chtt  => "Title",
      :chts  => "AA0000,12,c", # 12 == font size
      :chxt  => 'x,y',
      :chxr  => '1,1000,2500', # 0 == x-axis, 1 == y-axis
      :chds  => "1000,2500",
      :chxl  => "0:|Elevation",
      :chxp  => "0,50", # 0 == x-axis, 50 == center
      :chco  => "0000FF",
      :chls  => "4", # line thickness
      :chm   => "B,76A4FB,0,0,0" # blue fills under the line
    }.merge!(opts)
    chart_args[:chd] = 't:' + elevation.array.join(',')

    URI.escape "#{chart_base_url}?#{chart_args.to_params}"
  end

  def self.staticmap_uri(elevation, opts={})
    map_base_url = 'http://maps.googleapis.com/maps/api/staticmap'
    #
    # http://code.google.com/intl/pl-PL/apis/maps/documentation/staticmaps/

    # The Google Static Maps API creates maps in several formats, listed below:
    # * roadmap (default)
    # * satellite
    # * terrain
    # * hybrid

    # ?maptype=roadmap
    # &size=512x512
    # &markers=color:green|label:S|latitude,longitude
    # &markers=color:red|label:F|latitude,longitude
    # &sensor=false

    # @locations == 49.2710,19.9813|49.2324,19.9817

    locations = elevation.locations.split("|")

    map_args = {
      :maptype => "terrain",
      :size => "400x400",
      :markers => [
          "color:green|label:S|#{locations[0]}", "color:red|label:F|#{locations[1]}"
        ],
      :sensor => false
    }
    URI.escape("#{map_base_url}?#{map_args.to_params}").gsub /\[\d+\]/, ""
  end

  private

  def set_path_and_array_and_uri
    @uri = URI.escape "#{ELEVATION_BASE_URL}?#{@options.to_params}"

    response = Net::HTTP.get_response(URI.parse(@uri))
    @path = JSON.parse(response.body)['results']
    @array = @path.map do |x|
      x['elevation'].to_i
    end
  end

end


# Poor man's tests

if __FILE__ == $PROGRAM_NAME

  lon1 = 49.2710  # longitude = długość geograficzna
  lat1 = 19.9813  # latitude  = szerokość geograficzna
  lon2 = 49.2324
  lat2 = 19.9817

  puts "Kuźnice          longtitude: #{lon1}  latitude: #{lat1}"
  puts "Kasprowy Wierch  longtitude: #{lon2}  latitude: #{lat2}"

  distance = GeoDistance::Haversine.geo_distance(lat1, lon1, lat2, lon2).kms
  puts "Odległość między Kużnicami a Kasprowym Wierchem:\n\t#{distance}"

  samples = 44
  elevation = Elevation.new :samples => samples
  # puts elevation.array
  # puts "-" * 16
  # puts elevation.path
  # puts "-" * 16

  path = elevation.path

  lon1 = path[0]['location']['lng']
  lat1 = path[0]['location']['lat']
  lon2 = path[1]['location']['lng']
  lat2 = path[1]['location']['lat']
  puts GeoDistance::Haversine.geo_distance(lat1, lon1, lat2, lon2).kms * (samples-1)

  lon1 = path[1]['location']['lng']
  lat1 = path[1]['location']['lat']
  lon2 = path[2]['location']['lng']
  lat2 = path[2]['location']['lat']
  puts GeoDistance::Haversine.geo_distance(lat1, lon1, lat2, lon2).kms * (samples-1)

  puts "Distance: #{'%.3f' % elevation.distance} km"

  width = 100
  height = 100

  # na razie zostawiamy bez zmian:
  #    :chxr  => '1,1000,2500', # 0 == x-axis, 1 == y-axis
  #    :chds  => "1000,2500",
  #
  # ale szerokość obrazka skalujemy:
  #    :chs   => "450x200",

  puts "Chart uri:"
  puts "-" * 40
  puts Elevation.elevation_chart_uri elevation,
      :chtt  => "Z Kuźnic na Kasprowy Wierch",
      :chxl  => "0:|profil trasy",
      :chs => "800x375"  # = 300,000 max pixels allowable by Google API
  puts "-" * 40
  puts "Elevation: highest = #{elevation.highest}, lowest = #{elevation.lowest}"
  puts "-" * 40

  puts "Static map uri:"
  puts "-" * 40
  puts Elevation.staticmap_uri elevation

end
