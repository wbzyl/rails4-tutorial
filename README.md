# Rails 4

Gem z notatkami do wykładu „Architektura serwisów internetowych”.

Kod dla wersji 3 Ruby on Rails.


## Metody pomocnicze

Przykład linków do *pretty printing*:

    {%= link_to "scaffold", "/rails3/scaffold/posts_controller.rb" %}
    {%= link_to "nifty:scaffold", "/rails3/nifty-generators/comments_controller.rb" %}


## Ostateczne terminy oddania projektów

Czasami muszę wstawić coś takiego na stronie głównej aplikacji:

    <script>
    $(function () {
     deadline = new Date(2011, 06, 22);
     $('#defaultCountdown').countdown({
      until: deadline,
      compact: true,
      layout: '<b>{dn}{dl} {hnn}{sep}{mnn}{sep}{snn}</b>',
      format: 'dHMS'});
    });
    </script>
