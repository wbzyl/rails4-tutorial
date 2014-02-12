$(document).ready(function(){
  // OpenStreetMap
  var osm = {
    url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    link: '<a href="http://openstreetmap.org">OpenStreetMap</a>'
  };
  var attributions = {
    osm: '&copy; ' + osm.link + ' Contributors',
  };

  // Leafletjs – współrzędne: [ szerokość, długość ]
  var map = L.map('map').setView([52.05735, 19.19209], 6);  // Łęczyca

  L.tileLayer(osm.url, {
    attribution: attributions.osm
  }).addTo(map);

  // GeoJSON – współrzędne: [ długość, szerokość ]

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

  function addPopup(feature, layer) {
    layer.bindPopup(feature.properties.name + ', ' + feature.properties.popupContent);
  }

  L.geoJson(geojsonFeatures, {
    pointToLayer: function (feature, latlng) {
      return L.marker(latlng, { riseOnHover: true });
    },
    onEachFeature: addPopup
  }).addTo(map);

});
