angular.module("SustainabilityApp").controller "MapController", [
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
      newContribution:
        submit: ->
          new Contribution(@).create()
        features_attributes: []
        addFeature: (feature) ->
          feature.properties = { "stroke-width": 5.5 }
          @features_attributes.push { geojson: feature }
          return
    leafletData.getMap("map_main").then (map) ->
      window.map = map
      map.addControl($scope.drawControl)
      map.on "draw:created", (e) ->
        $scope.newContribution.addFeature e.layer.toGeoJSON()
        #Contribution.setTitle "#{Contribution.title} hallo"
        return
      return
    return
]
