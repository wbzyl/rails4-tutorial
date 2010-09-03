require 'rubygems'

require 'wb-rails3'

require 'rack/codehighlighter'
require 'uv'

#use Rack::ShowExceptions
#use Rack::Lint

use Rack::Codehighlighter, :ultraviolet, :markdown => true, :element => "pre>code"

run WB::Rails3.new
