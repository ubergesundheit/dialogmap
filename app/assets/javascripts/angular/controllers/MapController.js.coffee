App.controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  ($scope, leafletData, Contribution) ->
    angular.extend $scope,
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 10

      controls:
        draw:
          options:
            draw:
              polyline: false
              circle: false
            edit: false

    leafletData.getMap("map_main").then (map) ->
      window.map = map
      map.addControl($scope.drawControl)
      map.on "draw:created", (e) ->
        Contribution.addFeature e.layer.toGeoJSON()
        Contribution.setTitle "#{Contribution.title} hallo"
        return
      return
    return
]
