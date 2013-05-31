# Rails 4, wiosna 2012/13

Notatki do wykładu „Architektura serwisów internetowych”,
Ruby on Rails 4, Ruby 2.0.


## …ostateczne terminy oddania projektów

Czasami muszę wstawić coś takiego na stronie głównej aplikacji:

```js
$(function () {
  deadline = new Date(2013, 05, 31);
  $('#defaultCountdown').countdown({
    until: deadline,
    compact: true,
    layout: '<b>{dn}{dl} {hnn}{sep}{mnn}{sep}{snn}</b>',
    format: 'dHMS'
  });
});
```

## Google Analytics?

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
<script>!window.jQuery && document.write(unescape('%3Cscript src="/javascripts/libs/jquery-1.6.1.min.js"%3E%3C/script%3E'))</script>
<script>
  var _gaq=[['_setAccount','UA-20399167-1'],['_trackPageview']];
  (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];g.async=1;
  g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
  s.parentNode.insertBefore(g,s)}(document,'script'));
</script>
```
