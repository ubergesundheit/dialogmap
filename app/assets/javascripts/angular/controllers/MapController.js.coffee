angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "$compile"
  "leafletData"
  "Contribution"
  ($scope, $compile, leafletData, Contribution) ->
    L.Icon.Default.imagePath = 'assets/'
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
          enable: ['moveend', 'draw:created','click','popupopen']
          logic: 'emit'
      tiles:
        url: 'http://osm-bright-ms.herokuapp.com/v2/osmbright/{z}/{x}/{y}.png'
      geojson:
        data: { "type": "FeatureCollection", "features": [] }
        style: L.mapbox.simplestyle.style
        onEachFeature: (feature, layer) ->
          popupContent = "<div ng-include=\"'popupcontent_show.html'\"></div>"
          feature.mode = 'show'
          layer.bindPopup popupContent,
            minWidth: 250,
            feature: feature
          return

      updateGeoJSON: (data) ->
        $scope.map_main.then (map) ->
          bbox = map.getBounds().pad(1.005).toBBoxString()
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
            $scope.geojson =
              style: $scope.geojson.style
              onEachFeature: $scope.geojson.onEachFeature
              data: fcollection
            return
          return
        return

      # Contribution state
      composing: false
      addingFeature: false
      # Map Object use with .then (map) ->
      map_main: leafletData.getMap('map_main')
      addDrawControl: ->
        $scope.map_main.then (map) ->
          map.addControl($scope.drawControl)
          return
        return
      removeDrawControl: ->
        $scope.map_main.then (map) ->
          map.removeControl($scope.drawControl)
          return
        return

      # Contribution Object
      newContribution:
        references: []
        start: (feature) ->
          if feature?
            @reset()
            @references.push feature
          else
            @references = []
          $scope.removeDrawControl()
          $scope.composing = true
          return
        startAddFeatureReference: ->
          $scope.addingFeature = true
          $scope.addDrawControl()
          return
        stopAddFeatureReference: ->
          $scope.addingFeature = false
          $scope.removeDrawControl()
          return
        abort: ->
          @reset()
          $scope.composing = false
          $scope.addDrawControl()
          return
        reset: ->
          @title = ''
          @description = ''
          @references = []
          $scope.drawControl.options.edit.featureGroup.clearLayers()
          return
        submit: ->
          @features_attributes = ( { "geojson": feature } for feature in $scope.drawControl.options.edit.featureGroup.toGeoJSON().features)
          new Contribution(@).create().then (data) ->
            temp = $scope.geojson
            for feature in data.featuresAttributes
              do ->
                temp.data.features.push feature.geojson
                return
            #for feature in temp.data.features
            #  do ->
            #    $scope.geojson.data.features.push feature
            $scope.geojson =
              style: temp.style
              onEachFeature: temp.onEachFeature
              data: temp.data
            return
          @reset()
          $scope.composing = false
          return

    # init stuff
    # put the feature creation controls to the map because someone could want to create a new contribution
    # which gets started by creating a feature
    $scope.addDrawControl()
    $scope.$on 'leafletDirectiveMap.moveend', (evt) ->
      $scope.updateGeoJSON()
      return
    $scope.$on 'leafletDirectiveMap.draw:created', (evt,leafletEvent) ->
      console.log $scope.composing
      if $scope.composing == true and $scope.addingFeature == false
        $scope.newContribution.start()
      else
        $scope.composing = true
        $scope.newContribution.stopAddFeatureReference()
      layer = leafletEvent.leafletEvent.layer
      layer.options.properties = {}
      editFeatueScope = $scope.$new()
      popupContent = $compile('<div><input placeholder="Titel" class="input_title" ng_model="popups.title" /><div description-area ng_model="popups.description" highlights="popups.highlights"></div></div>')(editFeatueScope)
      layer.bindPopup popupContent[0],
        minWidth: 250
        feature: {}
      .openPopup();
      editFeatueScope.$watch 'popups', (value) ->
        layer.options.properties = value
        return
      return
    $scope.$on 'leafletDirectiveMap.popupopen', (evt, leafletEvent) ->
      feature = leafletEvent.leafletEvent.popup.options.feature
      if feature.mode == 'show'
        newScope = $scope.$new()
        newScope.feature = feature
        $compile(leafletEvent.leafletEvent.popup._contentNode)(newScope)

      return
    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      #console.log leafletEvent
      return
    return
]
