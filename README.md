# Rails 4

Gem z notatkami do wykładu „Architektura serwisów internetowych”.
Przykłady JTZ dla wersji Rails aż do 4.


## Instalacja

Wykonać polecenie:

    gem install rails4-tutorial


## Uruchamianie

Sprawdzamy gdzie w systemie został zainstalowany gem *wb-rails3*:

    gem which rails4-tutorial

Aplikację uruchamiamy tak:

<pre>rackup /«<i>ścieżka do katalogu z gemem</i>»/lib/config.ru -p 8008
</pre>

Na przykład:

    rackup /usr/lib/ruby/gems/1.8/gems/rails4-tutorial/lib/config.ru -p 8008

Po uruchomieniu aplikacja jest dostępna z URL:

    http://localhost:8008/


## Layout

Korzystam z frameworka [BlueprintCSS] [].
Layout korzysta z wygenerowanych plików i parametrach
pobranych z pliku *blueprint-css/settings.yml*::

    rails3:
      path: /opt/nginx/html/stylesheets/
      custom_layout:
        column_count: 25
        column_width: 20
        gutter_width: 20
      plugins:
        - buttons
        - link-icons
      semantic_classes:
        "#content": ".span-25, div.span-25"


### Fonty

[WC Rhesus](http://www.fontsquirrel.com/fonts/WC-Rhesus-Bta):
splatter, splash, paint, ink, drops, drips, dirty


[blueprintcss]: http://www.blueprintcss.org/ "Blueprint: A CSS Framework"
