gem "sinatra", "< 1.0"

require 'rdiscount'
require 'sinatra/base'
require 'sinatra/rdiscount'

require 'sinatra/url_for'
require 'sinatra/static_assets'

module WB
  class Rails4 < Sinatra::Base
    include Rack::Utils

    helpers Sinatra::UrlForHelper
    register Sinatra::StaticAssets

    # disable overriding public and views dirs
    set :app_file, __FILE__
    set :static, true  
    
    # the middleware stack can be used internally as well. I'm using it for
    # sessions, logging, and methodoverride. This lets us move stuff out of
    # Sinatra if it's better handled by a middleware component.
    set :logging, true  # use Rack::CommonLogger  
    
    helpers Sinatra::RDiscount
    
    # configure blocks:
    # configure :production do
    # end
    
    #before do
    #  mime :sql, 'text/plain; charset="UTF-8"' # when served by Sinatra itself
    #end

    # helper methods
    #attr_reader :title

    def page_title
      @title || ""
    end

    # def title=(name)... does not work, bug?
    def title(name)
      @title = " // #{name}"
    end
    
    get '/' do
      rdiscount :main
    end

    get %r{^([-_\w\/]+)\/([-_\w]+)\.((\w{1,4})(\.\w{1,4})?)$} do

      translate = { # to ultraviolet syntax names: uv -l syntax
        'html' => 'html',
        'html.erb' => 'html_rails',
        'text.erb' => 'html_rails',       
        'rb' => 'ruby_experimental',
        'ru' => 'ruby_experimental',
        'css' => 'css_experimental',
        'js' => 'jquery_javascript',
        'yml' => 'yaml',
        'sh' => 'shell-unix-generic'
      }
      
      content_type 'text/html', :charset => 'utf-8'

      dirname = params[:captures][0]
      name = params[:captures][1]
      extname = params[:captures][2]
      filename = name + "." + extname

      @title = filename
      @filename = File.expand_path(File.join(File.dirname(__FILE__), 'doc', dirname, filename))

      lang = translate[extname] || 'plain_text'
      
      if File.exists?(@filename) && File.readable?(@filename)
        content = "<pre><code>:::#{lang}\n#{escape_html(File.read @filename)}</code></pre>"
      else
        content = "<h2>oops! couldn't find <em>#{filename}</em></h2>"
      end

      erb content, :layout => :code
    end
    
    get '/:section' do
      rdiscount :"#{params[:section]}"
    end

     error do
      e = request.env['sinatra.error']
      Kernel.puts e.backtrace.join("\n")
      'Application error'
    end
    
    # each Sinatra::Base subclass has its own private middleware stack:
    # use Rack::Lint
  end
end

