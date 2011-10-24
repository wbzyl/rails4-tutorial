# -*- coding: utf-8 -*-
#
# Emacs package: ruby-compilation
#
#   C-x C-t  /  C-x t

require 'geo-distance'

# 49.2710,19.9813|49.2324,19.9817

lon1 = 49.2710  # longitude = długość geograficzna
lat1 = 19.9813  # latitude  = szerokość geograficzna
lon2 = 49.2324
lat2 = 19.9817

puts "Kuźnice          longtitude: #{lon1}  latitude: #{lat1}"
puts "Kasprowy Wierch  longtitude: #{lon2}  latitude: #{lat2}"

# kms, meters, miles, feet

puts GeoDistance::Haversine.geo_distance( lat1, lon1, lat2, lon2 ).kms
puts GeoDistance::Spherical.geo_distance( lat1, lon1, lat2, lon2 ).kms
puts GeoDistance::Vincenty.geo_distance( lat1, lon1, lat2, lon2 ).kms
puts GeoDistance::Flat.geo_distance( lat1, lon1, lat2, lon2 ).kms

GeoDistance.default_algorithm = :haversine

puts GeoDistance.distance( lat1, lon1, lat2, lon2 )


# GeoPoint.coord_mode = :lng_lat

# puts GeoDistance::Haversine.geo_distance( lon1, lat1, lon2, lat2).meters
# puts GeoDistance::Haversine.geo_distance( lon1, lat1, lon2, lat2).kms
