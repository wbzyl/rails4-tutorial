$(document).ready(function(){
  // GeoJSON features – współrzędne: [ długość, szerokość ]
  var geojsonFeatures = [
    { "type" : "Feature", "geometry" : { "type" : "Point", "coordinates" : [ 22.5142993927002, 49.6575012207031 ] }, "properties" : { "title" : "Arlamów Airport", "description" : "big_airport", "marker-size" : "medium", "marker-symbol" : "airport" } },
    { "type" : "Feature", "geometry" : { "type" : "Point", "coordinates" : [ 19.0018997192383, 49.8050003051758 ] }, "properties" : { "title" : "Bielsko Biala Airport", "description" : "small_airport", "marker-size" : "medium", "marker-symbol" : "airport" } }
  ];

  // OpenStreetMap data
  var osm = {
    url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> Contributors'
  };

  // create map – współrzędne: [ szerokość, długość ]
  var map = L.map('map').setView([52.05735, 19.19209], 6);  // center: Łęczyca, zoom: 6
  var osmTileLayer = L.tileLayer(osm.url, {attribution: osm.attribution})
  osmTileLayer.addTo(map);

  // add markers to map
  L.geoJson(geojsonFeatures, {
    pointToLayer: function (feature, latlng) {
      return L.marker(latlng, { riseOnHover: true });
    },
    onEachFeature: function(feature, layer) {
      layer.bindPopup(feature.properties.title + '<br>(' + feature.properties.description + ')');
    }
  }).addTo(map);

});
