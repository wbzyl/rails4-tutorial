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

    get %r{^([-_\w\/]+)\/([-_\w]+)\.((\w{1,4})(\.\w{1,8})?)$} do

      translate = { # to coderay syntax names
        'html.erb' => 'erb',
        'text.erb' => 'text',
        'erb' => 'erb',
        'rb' => 'ruby',
        'ru' => 'ruby',
        'json.jbuilder' => 'ruby',
        'js' => 'javascript',
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
