#### {% title "Makieta aplikacji, czyli layout" %}

<blockquote>
 <p>
  {%= image_tag "/images/html5-layout-1.png", :alt => "[HTML5 Layout 1.]" %}
 </p>
 <p class="author">źródło: <a href="http://scottgale.com/blog/wp-content/uploads/2010/04/html5-layout-sm.png">Scot Gale</a></p>
</blockquote>

Co oznacza słowo *layout*:

* makieta, układ graficzny strony, okładki, książki
* rozmieszczenie, rozplanowanie elementów na stronie
* rozkład, plan techniczny, kompozycja

*Rails Guides*,
[Layouts and Rendering in Rails](http://edgeguides.rubyonrails.org/layouts_and_rendering.html) –
this guide covers the basic layout features of Action Controller and Action View.

Projekt [web-app-theme](https://github.com/pilu/web-app-theme) (autor Andrea Franz)
jest drugi w kategorii „Most Watched Overall Javascript project” na githubie.


## Layout aplikacji

Przykładowy layout aplikacji, po liftingu
(pl, utf-8, domyślny tytuł):

    :::rhtml app/views/layouts/application.html.erb
    <!doctype html>
    <!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
    <!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="pl"> <![endif]-->
    <!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="pl"> <![endif]-->
    <!--[if IE 8]>    <html class="no-js lt-ie9" lang="pl"> <![endif]-->
    <!-- Consider adding a manifest.appcache: h5bp.com/d/Offline -->
    <!--[if gt IE 8]><!--> <html class="no-js" lang="pl"> <!--<![endif]-->
    <head>
      <meta charset="utf-8">

      <!-- Use the .htaccess and remove these lines to avoid edge case issues.
           More info: h5bp.com/b/378 -->
      <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

      <title><%= content_for?(:title) ? yield(:title) : "Fortunka" %></title>
      <meta name="description" content="">
      <meta name="author" content="">

      <!-- Mobile viewport optimized: j.mp/bplateviewport -->
      <meta name="viewport" content="width=device-width,initial-scale=1">

      <!-- Place favicon.ico and apple-touch-icon.png in the root directory: mathiasbynens.be/notes/touch-icons -->

      <%= stylesheet_link_tag "application" %>

      <!-- More ideas for your <head> here: h5bp.com/d/head-Tips -->

      <!-- All JavaScript at the bottom, except this Modernizr build incl. Respond.js
           Respond is a polyfill for min/max-width media queries. Modernizr enables HTML5 elements & feature detects;
           for optimal performance, create your own custom Modernizr build: www.modernizr.com/download/ -->
      <%= javascript_include_tag "application" %>
      <%= csrf_meta_tags %>
    </head>

    <body>
      <header>
         <%= content_tag :h1, "Fortunka" %>
      </header>
      <div role="main">
        <%= content_tag :h1, yield(:title) if show_title? %>
        <%= yield %>
      </div>
      <footer>
      </footer>
    </body>
    </html>

<blockquote>
 <p>
  {%= image_tag "/images/html5-blog.png", :alt => "[HTML5 Blog]" %}
 </p>
 <p class="author">źródło: <a href="http://html5doctor.com/designing-a-blog-with-html5/">html5 doctor</a></p>
</blockquote>

Generator *nifty:layout* definiuje kilka użytecznych metod
pomocniczych. Warto je dopisać do pliku *app/helpers/layout_helper.rb*:

    :::ruby
    module LayoutHelper
      def title(page_title, show_title = true)
        content_for(:title) { page_title.to_s }
        @show_title = show_title
      end
      def show_title?
        @show_title
      end

      def stylesheet(*args)
        content_for(:head) { stylesheet_link_tag(*args) }
      end
      def javascript(*args)
        content_for(:head) { javascript_include_tag(*args) }
      end
    end


## Linki

* Inayaili de León. [Have a Field Day with HTML5 Forms](http://24ways.org/2009/have-a-field-day-with-html5-forms)
* [Coding A HTML 5 Layout From Scratch](http://www.smashingmagazine.com/2009/08/04/designing-a-html-5-layout-from-scratch/)
* [Coding a CSS3 & HTML5 One-Page Website Template](http://tutorialzine.com/2010/02/html5-css3-website-template/)



# Co to są sitemaps?

Odpowiedzi udzielił [stJhimy](http://www.stjhimy.com/posts/2).

Przykładowy plik:

    :::xml
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>http://sinatra.local/rails3/</loc>
        <priority>1.0</priority>
      </url>
      <url>
        <loc>http://sinatra.local/rails3/fortunes/1</loc>
        <priority>1.0</priority>
      </url>
    </urlset>

Taki plik wygenerujemy korzystając z *XMLbuilder*:

    :::ruby
    xml.instruct!
    xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

      xml.url do
        xml.loc "http://sinatra.local/fortunes" # wstawiamy swój adres
        xml.priority 1.0
      end
      # dodajemy wszystkie fortunki (wystarczyłby indeks)
      @fortunes.each do |fortune|
        xml.url do
          xml.loc fortune_url(fortune)
          xml.priority 1.0
        end
      end
      # można dodać więcej linków, dla przykładu
      @posts.each do |post|
        xml.url do
          xml.loc post_url(post)
          xml.lastmod post.updated_at.to_date
          xml.priority 0.61
        end
      end
    end

Wcześniej definiujemy `@fortunes` i dodajemy routing, np.

    http://sinatra.local/fortunes/sitemap.xml

Na koniec aktywujemy sitemap dopisując w pliku *public/robots.txt*:

    Sitemap: http://wbzyl.inf.ug.edu.pl/fortunes/sitemap.xml

Albo wykonujemy ping:

    www.google.com/webmasters/tools/ping?sitemap=http://wbzyl.inf.ug.edu.pl/fortunes/sitemap.xml


<blockquote>
 <p>
  {%= image_tag "/images/article-page-layout.png", :alt => "[HTML5 Article Page Layout]" %}
 </p>
 <p class="author">źródło: <a href="http://boblet.tumblr.com/post/141239118/html5-structure4">@boblet</a></p>
</blockquote>

# Różne rzeczy…

**Aktywne zakładki.**
Dla przykładu, przyjmijmy, że na każdej stronie naszej aplikacji
wyświetlamy trzy zakładki *Homepage*, *About us* oraz *Contact*,
a kod elementu HTML z zakładkami, gdy jesteśmy na stronie *Homepage*
ma wyglądać tak:

    :::html
    <div id="mainMenu">
      <ul>
        <li class="active"><a href="/home">Homepage</a></li>
        <li><a href="/about">About us</a></li>
        <li><a href="/contact">Contact</a></li>
      </ul>
    </div>

czyli element listy *ul* z linkiem do strony na której aktualnie jesteśmy
powinien mieć dodany atrybut **class** ustawiony na **active**.

A tak chcielibyśmy, to wpisać layoucie *views/layouts/application.html.erb*:

    :::rhtml
    <div id="mainMenu">
      <%= navigation ['/home','Homepage'],['/about','About us'],['/contact','Contact'] %>
    </div>

Poniższy kod, po wpisaniu w *helpers/layout_helper.rb*, realizuje takie podejście:

    :::ruby
    def navigation(*data)
      content_tag :ul do
        data.map do |link, name|
          content_tag :li, link_to("#{name}", link),
              :class => ("active" if controller.controller_name == link[1,link.length])
        end
      end
    end

Gotowy przykład, zob. *labs/003-Tabbed_Navigation*.

Na koniec kilka linków na ten temat:

* [Selected Tab Navigation](http://railsforum.com/viewtopic.php?id=30174)
* [TabsOnRails: Creating and managing Tabs with Ruby on Rails](http://code.simonecarletti.com/projects/tabsonrails/wiki)

**Zagnieżdzone layouty z content_for.**
Załóżmy, że aplikacja składa się z trzech kontrolerów:

* HomeController
* AboutController
* ContactController

i wszystkie kontrolery używają jednego layoutu – *application.html.erb*.

Przypuśćmy, że layouty dla kontrolerów muszą się nieco różnić,
dla przykładu – kolorem tła.

Zamiast powielenia i edycji *layouts/application.html.erb* można
postąpić tak. Tworzymy plik *layouts/about.html.erb* o zawartości:

    :::rhtml
    <% content_for :head do %>
      <style>
        #background { background-color: #956E6F; }
      </style>
    <% end -%>
    <%= render :file => 'layouts/application' %>

i według tego schematu tworzymy plik *layouts/contact.html.erb*.
