angular.module('SustainabilityApp').service "propertiesHelper", ->
  @createProperties = (title,leaflet_id,type) ->
    properties = { "title": title, "leaflet_id": leaflet_id }
    if type == "Point"
      properties["marker-size"] = "medium"
      properties["marker-symbol"] = "circle-stroked"
      properties["marker-color"] = "#004e00"
    else if type == "Polygon"
      properties["stroke"] = "#629d62"
      properties["stroke-opacity"] = 1.0
      properties["stroke-width"] = 1.0
      properties["fill"] = "#3bc43b"
      properties["fill-opacity"] = 0.6
    properties
  return
