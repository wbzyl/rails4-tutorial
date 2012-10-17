#### {% title "Layout, czyli makieta aplikacji" %}

<blockquote>
 <p>
  {%= image_tag "/images/html5-blog.png", :alt => "[HTML5 Blog]" %}
 </p>
 <p class="author">źródło: <a href="http://html5doctor.com/designing-a-blog-with-html5/">html5 doctor</a></p>
</blockquote>

Co oznacza słowo *layout*:

* makieta, układ graficzny strony, okładki, książki
* rozmieszczenie, rozplanowanie elementów na stronie
* rozkład, plan techniczny, kompozycja

Jak korzystać z layoutów w aplikacjach Rails opisano w przewodniku
[Layouts and Rendering in Rails](http://guides.rubyonrails.org/layouts_and_rendering.html).

Layout na dobry początek: [HTML KickStart](http://www.99lime.com/) –
is an ultra–lean set of HTML5, CSS, and jQuery (javascript) files,
layouts, and elements designed to give you a headstart and save you
10’s of hours on your next web project.

Layout „HTML KickStart” przystosowujemy do Rails analogicznie jak to
zrobiono dla layoutu Twitter Bootstrap w rozdziale 5
[Filling in the layout](http://ruby.railstutorial.org/chapters/filling-in-the-layout#top)
„Ruby on Rails Tutorial” M. Hartla.

Różne rzeczy na ten temat:

* [The Rails 3 asset pipeline in (about) 5 minutes](http://2beards.net/2011/11/the-rails-3-asset-pipeline-in-about-5-minutes/)


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
Piszemy metodę pomocniczą, przykładowo:

    :::ruby
    def link_to_page(where, path)
      content_tag(:li,
          link_to_unless_current(where, path),
          class: current_page?(path) ? "active" : nil)
    end

Dodajemy nieco CSS:

    :::css
    li.active {
      font-weight: bold;
      color: red;
    }

i już! gotowe do użycia:

    :::rhtml
    <%= link_to_page("Aktualności", root_path) %>
    <%= link_to_page("Podstawowe informacje", informacje_path) %>

<!--

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
              # :class => ("active" if controller.controller_name == link[1,link.length])
              :class => ("active" if controller.controller_name == link[1..-1])
        end
      end
    end

Gotowy przykład, zob. *labs/003-Tabbed_Navigation*.

Na koniec kilka linków na ten temat:

* [Selected Tab Navigation](http://railsforum.com/viewtopic.php?id=30174)
* [TabsOnRails: Creating and managing Tabs with Ruby on Rails](http://code.simonecarletti.com/projects/tabsonrails/wiki)

-->

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

a w layoucie aplikacji *application.html.erb* w pojemniku *head* dopisujemy:

    :::rhtml
    <%= yield(:head) %>

i według tego schematu tworzymy plik *layouts/contact.html.erb*.
