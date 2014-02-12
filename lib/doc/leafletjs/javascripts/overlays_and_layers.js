// TODO: convert to plugin

var osm = {
  url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  link: '<a href="http://openstreetmap.org">OpenStreetMap</a>'
};

var thunderforest = {
  url : {
    landscape: 'http://{s}.tile.thunderforest.com/landscape/{z}/{x}/{y}.png',
    outdoors:  'http://{s}.tile.thunderforest.com/outdoors/{z}/{x}/{y}.png',
    cycle: 'http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png'
  },
  link: '<a href="http://thunderforest.com/">Thunderforest</a>'
};

var attributions = {
  osm: '&copy; ' + osm.link + ' Contributors',
  thunderforest: '&copy; '+osm.link+' Contributors & '+thunderforest.link
};

// Leaflet part

$(document).ready(function() {

  var myPlaces = new L.LayerGroup();

  L.marker([49.29196, 19.94800])
    .bindPopup('„U Samanty” – Kasprusie 34, Zakopane').addTo(myPlaces);
  L.marker([49.23175, 19.98158])
    .bindPopup('Kasprowy Wierch, 1987 n.p.m.').addTo(myPlaces);

  var osmMap = L.tileLayer(osm.url, {attribution: attributions.osm}),
    landscapeMap = L.tileLayer(thunderforest.url.landscape, {attribution: attributions.thunderforest}),
    outdoorsMap = L.tileLayer(thunderforest.url.outdoors, {attribution: attributions.thunderforest}),
    cycleMap = L.tileLayer(thunderforest.url.cycle, {attribution: attributions.thunderforest});

  var map = L.map('map', {
    layers: [osmMap]  // only add one!
  })
    .setView([49.29196, 19.94800], 13); // U Samanty

  var baseLayers = {
    "OSM Mapnik": osmMap,
    "Landscape": landscapeMap,
    "Outdoors": outdoorsMap,
    "Cycle": cycleMap
  };

  var overlays = {
    "My Places": myPlaces
  };

  L.control.layers(baseLayers,overlays).addTo(map);


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
