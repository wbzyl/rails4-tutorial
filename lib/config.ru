require 'rubygems'
#require 'bundler/setup'

require 'rails4-tutorial'

require 'rack/codehighlighter'
require 'uv'

#use Rack::ShowExceptions
#use Rack::Lint

use Rack::Codehighlighter, :ultraviolet, :markdown => true, :element => "pre>code"

run WB::Rails4.new
