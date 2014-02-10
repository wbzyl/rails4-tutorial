// https://github.com/mapbox/simplestyle-spec/tree/master/1.1.0

var cursor = db.airports.find({iso_country: "PL"})

// var spec = {
//   "type": "Feature",
//   "geometry": {
//     "type": "Point",
//     "coordinates": [0, 0]
//   },
//   "properties": {
//     // a title to show when this item is clicked or hovered over
//     "title": "Konstancin-Jeziorna Airfield",  // name
//     // a description to show when this item is clicked or hovered over
//     "description": "small_airport", // type

//     "marker-size": "medium",
//     "marker-symbol": "airport",
//   }
// };

while (cursor.hasNext()) {
  var doc = cursor.next()
  var spec = {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [doc["longitude_deg"], doc["latitude_deg"]]
    },
    "properties": {
      // a title to show when this item is clicked or hovered over
      "title": doc["name"],
      // a description to show when this item is clicked or hovered over
      "description": doc["type"],

      "marker-size": "medium",
      "marker-symbol": "airport"
    }
  };
  db.lotniska.insert(spec);
  // printjson(spec);
}
