# -*- coding: utf-8 -*-

# Zamiast Google image graph api
# użyć biblioteki JavaScript [dygraphs](http://dygraphs.com/)

require 'json'                     # zbędne w Rails
require 'active_support/core_ext'  # ditto
require 'net/http'                 # Ruby Standard Library
require 'geo-distance'             # dopisać gem 'geo-distance' do Gemfile

# Dokumentacja:
#
#   http://www.ruby-doc.org/stdlib/
#   http://rubydoc.info/gems/geo-distance/0.2.0/frames
#
#   albo geo_calc:
#       http://rubydoc.info/gems/geo_calc/0.7.6/frames

# https://github.com/chneukirchen/styleguide/blob/master/RUBY-STYLE

class Elevation

  ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json'

  attr_accessor :locations, :track, :profile, :distance, :highest, :lowest, :uri

  def initialize(opts={})
    @options = {
      # Google Earth: Kuźnice            |Kasprowy Wierch
      :locations  => "49.269604,19.980100|49.232362,19.981650",
      :samples    => 4,
      :sensor     => false
    }.merge!(opts)
    @locations = @options.delete(:locations)
    @options[:path] = @locations # API Google: w uri ma być 'path' a nie 'locations'

    set_profile_and_track_and_uri

    @distance = GeoDistance::Haversine.geo_distance(*two_adjacent_points_from_track).kms *
      (@options[:samples]-1)

    @highest = @profile.max
    @lowest  = @profile.min
  end

  private

  def set_profile_and_track_and_uri
    @uri = "#{ELEVATION_BASE_URL}?#{@options.to_query}"
    response = Net::HTTP.get_response(URI.parse(@uri))

    # if response.code == "200"
    #   puts "This URI works: #{uri}"
    # else
    #   puts "TODO: wstawić jakąś trasę – po jakimś południku?"
    # end

    @track = JSON.parse(response.body)['results']
    @profile = @track.map do |x|
      x['elevation'].to_i
    end
  end

  def two_adjacent_points_from_track
    return @track[0]['location']['lng'],
        @track[0]['location']['lat'],
        @track[1]['location']['lng'],
        @track[1]['location']['lat']
  end

end


# Poor man's tests

if __FILE__ == $PROGRAM_NAME

  require 'pp'

  # test Elevation

  elevation = Elevation.new :samples => 17

  puts "-" * 44
  puts "Z Kużnic na Kasprowy Wierch:"
  puts "\n\tlocations: #{elevation.locations}"
  puts "\tdistance: #{'%.3f' % elevation.distance} km"

  puts "-" * 44
  puts elevation.uri
  puts "profile: #{elevation.profile}"
  puts "[lowest, highest] = [#{elevation.lowest}, #{elevation.highest}]"

  # ----------------------------------------------------------------
  # Czy elevation_chart_uri i staticmap_uri to metody pomocnicze ?
  #
  # Wkleić kod metod oraz dopisać do aplication_controller.rb:
  #
  #   helper_method :elevation_chart_uri, :staticmap_uri

  # http://www.damnhandy.com/2011/01/18/url-vs-uri-vs-urn-the-confusion-continues/

  def elevation_chart_uri(profile, distance, opts={})
    chart_base_url = 'http://chart.apis.google.com/chart'
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html

    margins = 30 # zgrubne przybliżenie; z gimpa
    width = (distance * (200/(1.5 * 2))).to_i + margins  # 1.5 = 1500 m
    chs = "#{width}x#{200}"

    chart_args = {
      :cht   => "lc",
      :chs   => chs,
      # optional margins
      :chma  => "0,0,0,0|0,0", # nie działa dolny margines -- dlaczego?
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
    chart_args[:chd] = 't:' + profile.join(',')

    return "#{chart_base_url}?#{chart_args.to_query}"
  end

  puts "-" * 44
  puts "Chart uri:"
  puts elevation_chart_uri elevation.profile, elevation.distance,
     :chtt  => "Z Kuźnic na Kasprowy Wierch",
     :chxl  => "0:|profil trasy",
     :chs => "800x375"  # = 300,000 max pixels allowable by Google API


  def staticmap_uri(locations, opts={})
    map_base_url = 'http://maps.googleapis.com/maps/api/staticmap'
    #
    # http://code.google.com/intl/pl-PL/apis/maps/documentation/staticmaps/

    # The Google Static Maps API creates maps in several formats, listed below:
    # * roadmap (default)
    # * satellite
    # * terrain
    # * hybrid

    # ?maptype=roadmap
    # &size=640x400
    # &markers=color:green|label:S|latitude,longitude
    # &markers=color:red|label:F|latitude,longitude
    # &sensor=false

    # locations == 49.2710,19.9813|49.2324,19.9817
    locs = locations.split("|")

    map_args = {
      :maptype => "terrain",
      :size => "400x400",
      :markers => [
          "color:green|label:S|#{locs[0]}", "color:red|label:F|#{locs[1]}"
        ],
      :sensor => false
    }.merge!(opts)

    return "#{map_base_url}?#{map_args.to_query}".gsub(/%5B%5D/, "") # remove []

  end

  puts "-" * 44
  puts "Static map uri:"
  puts staticmap_uri elevation.locations,
    :size => "640x400" # max allowable size?
  puts "-" * 44

end
