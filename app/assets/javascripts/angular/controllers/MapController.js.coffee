angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  ($scope, leafletData, Contribution) ->
    angular.extend $scope,
      # leaflet-directive stuff
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 14
      controls:
        draw:
          options:
            draw:
              polyline: false
              circle: false
      events:
        map:
          enable: ['moveend', 'draw:created']
          logic: 'emit'

      updateGeoJSON: ->
        $scope.map_main.then (map) ->
          bbox = map.getBounds().pad(1.01).toBBoxString()
          Contribution.query({bbox: bbox}).then (cts) ->
            fcollection =
              type: 'FeatureCollection'
              features: []
            for c in cts
              do ->
                if c.features.length > 0
                  for f in c.features
                    do ->
                      fcollection.features.push f
                      return
                return
            $scope.geojson = {}
            $scope.geojson.data = fcollection
            return
          return
        return

      # Contribution state
      composing: false
      # Map Object use with .then (map) ->
      map_main: leafletData.getMap('map_main')

      # Contribution Object
      newContribution:
        start: ->
          @reset()
          $scope.composing = true
          return
        abort: ->
          @reset()
          $scope.composing = false
          return
        reset: ->
          @title = ''
          @description = ''
          $scope.drawControl.options.edit.featureGroup.clearLayers()
          return
        submit: ->
          @features_attributes = ( { "geojson": feature } for feature in $scope.drawControl.options.edit.featureGroup.toGeoJSON().features)
          new Contribution(@).create().then (data) ->
            temp = $scope.geojson
            $scope.geojson = {}
            $scope.geojson.data =
              type: "FeatureCollection"
              features: []
            for feature in data.featuresAttributes
              do ->
                $scope.geojson.data.features.push feature.geojson
                return
            for feature in temp.data.features
              do ->
                $scope.geojson.data.features.push feature
            return
          @reset()
          return

    $scope.updateGeoJSON()
    $scope.$on 'leafletDirectiveMap.moveend', (evt) ->
      $scope.updateGeoJSON()
      return
    $scope.$on 'leafletDirectiveMap.draw:created', (evt,leafletEvent) ->
      $scope.composing = true
      layer = leafletEvent.leafletEvent.layer
      window.l = layer
      layer.bindPopup('<tags-input ng-model="newContribution.title"></tags-input>').openPopup();
      return
    return
]
