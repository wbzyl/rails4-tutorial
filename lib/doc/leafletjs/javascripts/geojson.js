$(document).ready(function(){
  // GeoJSON features – współrzędne: [ długość, szerokość ]
  var geojsonFeatures = [
    {
      "type": "Feature",
      "properties": {
        "name": "BUG",
        "popupContent": "Biblioteka Uniwersytetu Gdańskiego"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [18.5828, 54.39114]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "name": "U Samanty",
        "popupContent": "Kasprusie 34, Zakopane"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [19.94800, 49.29196]
      }
    }
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
      layer.bindPopup(feature.properties.name + ', ' + feature.properties.popupContent);
    }
  }).addTo(map);

});
