$(document).ready(function(){

  // CloudMade

  var cloudmade = {
    url: 'http://{s}.tile.cloudmade.com/122e9f998d6244fc90ef5dbbe89f7907/997/256/{z}/{x}/{y}.png',
    link: '<a href="http://openstreetmap.org">OpenStreetMap</a>',
    license : '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    imagery: '<a href="http://cloudmade.com">CloudMade</a>'
  };

  var attributions = {
    cloudmade: 'Map data &copy; ' + cloudmade.link +
      ' contributors, ' + cloudmade.license +
      ', Imagery © ' + cloudmade.imagery
  };

  // Leafletjs – współrzędne: [ szerokość, długość ]

  var map = L.map('map').setView([52.134, 19.276], 6);

  L.tileLayer(cloudmade.url, {
    attribution: attributions.cloudmade,
    maxZoom: 18
  }).addTo(map);


  // Marker

  var marker = L.marker([52.13349, 19.27551]).addTo(map);
  // marker.bindPopup("Somewhere in the center of Poland.").openPopup();
  marker.bindPopup("Somewhere in the center of Poland.");


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

  var geojsonMarkerOptions = {
    riseOnHover: true
  };

  function addPopup(feature, layer) {
    layer.bindPopup(feature.properties.name + ', ' + feature.properties.popupContent);
  }

  L.geoJson(geojsonFeatures, {
    pointToLayer: function (feature, latlng) {
      return L.marker(latlng, geojsonMarkerOptions);
    },
    onEachFeature: addPopup
  }).addTo(map);


  // Debug coordinates

  var popup = L.popup();
  function onMapClick(e) {
    popup
      .setLatLng(e.latlng)
      .setContent("You clicked the map at " + e.latlng.toString())
      .openOn(map);
  }
  map.on('click', onMapClick);


});

