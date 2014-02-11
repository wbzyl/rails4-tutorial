// Leafletjs – współrzędne: [ szerokość, długość ]

var map = L.map('map').setView([52.134, 19.276], 6);
// http://cloudmade.com/documentation/map-tiles#examples

L.tileLayer('http://{s}.tile.cloudmade.com/122e9f998d6244fc90ef5dbbe89f7907/997/256/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
    maxZoom: 18
}).addTo(map);


// Marker

var marker = L.marker([52.13349, 19.27551]).addTo(map);
// marker.bindPopup("Somewhere in the center of Poland.").openPopup();
marker.bindPopup("Somewhere in the center of Poland.");


// GeoJSON – współrzędne: [ długość, szerokość ]

var geojsonFeature = {
  "type": "Feature",
  "properties": {
    "name": "BUG",
    "popupContent": "Biblioteka Uniwersytetu Gdańskiego"
  },
  "geometry": {
    "type": "Point",
    "coordinates": [18.5828, 54.39114]
  }
};

var geojsonMarkerOptions = {
  title: "BUG",
  riseOnHover: true
};

L.geoJson(geojsonFeature, {
  pointToLayer: function (feature, latlng) {
    return L.marker(latlng, geojsonMarkerOptions).bindPopup("Biblioteka Uniwersytetu Gdańskiego");;
  }
}).addTo(map);


// TODO: array of GeoJSONs

// http://leafletjs.com/examples/geojson.html

// Debug coordinates

var popup = L.popup();
function onMapClick(e) {
  popup
    .setLatLng(e.latlng)
    .setContent("You clicked the map at " + e.latlng.toString())
    .openOn(map);
}
map.on('click', onMapClick);
