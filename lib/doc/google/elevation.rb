# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

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
  CHART_BASE_URL = 'http://chart.apis.google.com/chart'

  attr_accessor :elevation_array

  def initialize(opts={})
    @elvtn_args = {
      :path => "49.2710,19.9813|49.2324,19.9817",
      :samples => 10,
      :sensor => false
    }.merge!(opts)
  end

  def get_chart(opts={})
    #
    # http://code.google.com/intl/pl-PL/apis/chart/image/
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/chart_params.html
    # http://code.google.com/intl/pl-PL/apis/chart/image/docs/post_requests.html
    #
    chart_args = {
      :cht   => "lc",
      :chs   => "450x200",
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

    get_elevation_array

    dataString = 't:' + @elevation_array.join(',')
    chart_args[:chd] = dataString;

    URI.escape "#{CHART_BASE_URL}?#{chart_args.to_params}"
  end

  private

  def get_elevation_array
    url = URI.escape "#{ELEVATION_BASE_URL}?#{@elvtn_args.to_params}"
    response = Net::HTTP.get_response(URI.parse(url))
    response_array = JSON.parse(response.body)['results']

    @elevation_array = response_array.map do |x|
      x['elevation'].to_i
    end
  end

end


if __FILE__ == $PROGRAM_NAME

  elevation = Elevation.new :samples => 40
  puts elevation.get_chart :chtt  => "Z Kuźnic na Kasprowy Wierch", :chxl  => "0:|profil trasy"

end
