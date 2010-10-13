require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rails4-tutorial"
  s.version     = WBRails4::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Wlodek Bzyl"]
  s.email       = ["matwb@ug.edu.pl"]
  s.homepage    = "http://github.com/wbzyl/wb-rails"
  s.summary     = "A new gem templates"
  s.description = "You're definitely going to want to replace a lot of this"

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project = "rails4-tutorial"

  # If you have other dependencies, add them here
  s.add_dependency "rack", "> 1.0"
  s.add_dependency "sinatra", "< 1.0"
  s.add_dependency "sinatra-static-assets", ">= 1.0"
  s.add_dependency "rdiscount", "> 0"
  s.add_dependency "ultraviolet", "> 0"
  s.add_dependency "sinatra-rdiscount", "> 0"
  s.add_dependency "rack-codehighlighter", "> 0"

  # If you need to check in files that aren't .rb files, add them here
  s.files = Dir["{lib}/rails4-tutorial.rb",
                "{lib}/config.ru",
                "{lib}/public/**/*",
                "{lib}/views/**/*",
                "LICENSE",
                "*.md"]
  s.require_path = 'lib'
end
