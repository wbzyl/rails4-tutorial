# http://stackoverflow.com/questions/4980877/rails-error-couldnt-parse-yaml
require 'yaml'
YAML::ENGINE.yamler= 'syck'

require 'bundler'

Bundler.require

require 'rails4-tutorial'

require 'uv'
require 'rack/codehighlighter'

use Rack::Codehighlighter, :ultraviolet, :markdown => true, :element => "pre>code"

run WB::Rails4.new
