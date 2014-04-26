App.controller "MapController", [
  "$scope"
  "leafletData"
  ($scope, leafletData) ->
    angular.extend $scope,
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 10

      controls:
        draw: {}

    leafletData.getMap("map_main").then (map) ->
      map.on "draw:created", (e) ->
        console.log e.layer.toGeoJSON()
        return
      return
    return
]
