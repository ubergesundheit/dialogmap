angular.module('DialogMapApp').service "propertiesHelper", ->
  @createProperties = (title, type, color) ->
    properties = { "title": title }
    if type == "Point"
      properties["marker-size"] = "medium"
      properties["marker-symbol"] = "circle-stroked"
      properties["marker-color"] = color
    else if type == "Polygon"
      properties["stroke"] = color
      properties["stroke-opacity"] = 1.0
      properties["stroke-width"] = 1.0
      properties["fill"] = color
      properties["fill-opacity"] = 0.5
    properties
  return
