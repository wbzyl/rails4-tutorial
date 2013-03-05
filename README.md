# Rails 4, wiosna 2012/13

Notatki do wykładu „Architektura serwisów internetowych”,
Ruby on Rails v3.


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
