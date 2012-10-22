#### {% title "Piszemy PDF renderer" %}

Zobacz też [EngineX](https://github.com/josevalim/enginex):

    :::bash
    rails plugin new pdf_renderer --full
    cd pdf-renderer
    rake -T
      ...
      rake app:db:migrate  # Migrate the database (options: VERSION=x, VERBOSE=false)
      ...
      rake build        # Build pdf_renderer-0.0.1.gem into the pkg directory
      rake clobber_rdoc # Remove RDoc HTML files
      rake install      # Build and install pdf_renderer-0.0.1.gem into system gems
      rake rdoc         # Build RDoc HTML files
      rake release      # Create tag v0.0.1 and build and push pdf_renderer-0.0.1.gem to Rubygems
      rake rerdoc       # Rebuild RDoc HTML files
      rake test         # Run tests

Edytujemy *pdf_renderer.gemspec*:

    :::ruby
    $:.push File.expand_path("../lib", __FILE__)

    # Maintain your gem's version:
    require "pdf_renderer/version"

    # Describe your gem and declare its dependencies:
    Gem::Specification.new do |s|
      s.name        = "pdf_renderer"
      s.version     = PdfRenderer::VERSION
      s.authors     = ["TODO: Your name"]
      s.email       = ["TODO: Your email"]
      s.homepage    = "TODO"
      s.summary     = "TODO: Summary of PdfRenderer."
      s.description = "TODO: Description of PdfRenderer."

      s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
      s.test_files = Dir["test/**/*"]

      s.add_dependency "rails", "~> 3.2.8"
      # s.add_dependency "jquery-rails"

      s.add_development_dependency "sqlite3"
    end

Uruchamiamy *Dummy::Application*:

    :::ruby test/dummy/config/boot.rb
    require 'rubygems'
    gemfile = File.expand_path('../../../../Gemfile', __FILE__)

    if File.exist?(gemfile)
      ENV['BUNDLE_GEMFILE'] = gemfile
      require 'bundler'
      Bundler.setup
    end

    $:.unshift File.expand_path('../../../../lib', __FILE__)

Testujemy gem:

    :::bash
    rake test

Integration test, gdzie dodajemy dopisujemy *Capybara* metody pomocnicze Rails:

    :::ruby
    require 'test_helper'

    class NavigationTest < ActionDispatch::IntegrationTest
      fixtures :all

      include Capybara
      include Rails.application.routes.url_helpers

      # test "the truth" do
      #   assert true
      # end
    end
