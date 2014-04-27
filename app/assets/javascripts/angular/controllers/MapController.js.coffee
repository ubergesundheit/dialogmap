angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  ($scope, leafletData, Contribution) ->
    Contribution.query().then (cts) ->
      fcollection =
        type: 'FeatureCollection'
        features: []
      for c in cts
        do ->
          if c.features.length > 0
            for f in c.features
              do ->
                fcollection.features.push f
      $scope.geojson = {}
      $scope.geojson.data = fcollection
      return

    angular.extend $scope,
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 10
      controls:
        draw:
          options:
            position: 'topright'
            draw:
              polyline: false
              circle: false
            edit: false
      composing: false
      map_main: leafletData.getMap('map_main')
      newContribution:
        start: ->
          @reset()
          $scope.composing = true
          $scope.map_main.then (map) ->
            map.addControl($scope.drawControl)
            return
          return
        abort: ->
          @reset()
          $scope.composing = false
        reset: ->
          @title = ''
          @description = ''
          @features_attributes = []
        submit: ->
          new Contribution(@).create()
          @reset()
        features_attributes: []
        addFeature: (feature) ->
          feature.properties = { "stroke-width": 5.5 }
          @features_attributes.push { geojson: feature }
          return

    $scope.map_main.then (map) ->
      window.map = map
      map.on "draw:created", (e) ->
        $scope.newContribution.addFeature e.layer.toGeoJSON()
        #Contribution.setTitle "#{Contribution.title} hallo"
        return
      return
    return
]
