require 'bundler'

Bundler.require

require 'rails4-tutorial'

require 'coderay'
require 'rack/codehighlighter'

#use Rack::ShowExceptions
use Rack::Codehighlighter, :coderay, :markdown => true, :element => "pre>code"

run WB::Rails4.new
