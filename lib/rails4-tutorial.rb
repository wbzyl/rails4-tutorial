# -*- coding: utf-8 -*-

require 'rdiscount'
require 'erubis'

require 'sinatra/base'

require 'sinatra/static_assets'
require 'sinatra/filler'

module WB
  class Rails4 < Sinatra::Base
    register Sinatra::StaticAssets

    # disable overriding public and views dirs
    settings.app_file = __FILE__
    settings.static = true

    set :erb, :pattern => '\{% %\}', :trim => true
    set :markdown, :layout => false

    # the middleware stack can be used internally as well. I'm using it for
    # sessions, logging, and methodoverride. This lets us move stuff out of
    # Sinatra if it's better handled by a middleware component.
    set :logging, true  # use Rack::CommonLogger

    # helper methods
    helpers Sinatra::Filler

    # configure blocks:
    # configure :production do
    # end

    #before do
    #  mime :sql, 'text/plain; charset="UTF-8"' # when served by Sinatra itself
    #end

    # helper methods
    #attr_reader :title

    # def page_title
    #   @title || ""
    # end

    # # def title=(name)... does not work, bug?
    # def title(name)
    #   @title = " // #{name}"
    # end

    get '/' do
      erb(markdown(:main))
    end

    get '/:section' do
      erb(markdown(:"#{params[:section]}"))
    end

    get %r{^([-_\w\/]+)\/([-_\w]+)\.((\w{1,4})(\.\w{1,4})?)$} do

# clojure.rb:      register_for :clojure
# cpp.rb:    register_for :cpp
# c.rb:    register_for :c
# css.rb:    register_for :css
# debug.rb:    register_for :debug
# delphi.rb:    register_for :delphi
# diff.rb:    register_for :diff
# erb.rb:    register_for :erb
# groovy.rb:    register_for :groovy
# haml.rb:    register_for :haml
# html.rb:    register_for :html
# java.rb:    register_for :java
# java_script.rb:    register_for :java_script
# json.rb:    register_for :json
# php.rb:    register_for :php
# python.rb:    register_for :python
# raydebug.rb:    register_for :raydebug
# ruby.rb:    register_for :ruby
# sql.rb:    register_for :sql
# text.rb:      register_for :text
# xml.rb:    register_for :xml
# yaml.rb:    register_for :yaml


      translate = { # to ultraviolet syntax names: uv -l syntax
        'html.erb' => 'erb',
        'text.erb' => 'text',
        'rb' => 'ruby',
        'ru' => 'ruby',
        'js' => 'java_script',
        'yml' => 'yaml',
        'sh' => 'bash',
        'sql' => 'sql',
        'json' => 'json',
        'c' => 'c'
      }

      content_type 'text/html', :charset => 'utf-8'

      dirname = params[:captures][0]
      name = params[:captures][1]
      extname = params[:captures][2]
      filename = name + "." + extname

      @title =  'WB@Rails4' + dirname.split('/').join(' » ')

      @filename = File.expand_path(File.join(File.dirname(__FILE__), 'doc', dirname, filename))

      lang = translate[extname] || 'plain_text'

      if File.exists?(@filename) && File.readable?(@filename)
        content = "<h1>#{filename}</h1>"
        content += "<pre><code>:::#{lang}\n#{escape_html(File.read @filename)}</code></pre>"
        #content += "<pre><code>:::#{lang}\n#{File.read(@filename)}</code></pre>"
      else
        content = "<h2>oops! couldn't find <em>#{filename}</em></h2>"
      end

      erb content, :layout => :code
    end

    error do
      e = request.env['sinatra.error']
      Kernel.puts e.backtrace.join("\n")
      'Application error'
    end

  end
end
