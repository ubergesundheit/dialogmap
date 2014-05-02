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
        style:
          fillColor: "green",
          weight: 2,
          opacity: 1,
          color: 'white',
          dashArray: '3',
          fillOpacity: 0.7
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
      # Map Object use with .then (map) ->
      map_main: leafletData.getMap('map_main')

      # Contribution Object
      newContribution:
        omfg: ['wurst']
        start: ->
          @reset()
          $scope.composing = true
          return
        abort: ->
          console.log @description
          @reset()
          $scope.composing = false
          return
        reset: ->
          @title = ''
          @description = {}
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
    #$scope.updateGeoJSON()
    $scope.$on 'leafletDirectiveMap.moveend', (evt) ->
      $scope.updateGeoJSON()
      return
    $scope.$on 'leafletDirectiveMap.draw:created', (evt,leafletEvent) ->
      $scope.composing = true
      layer = leafletEvent.leafletEvent.layer
      id = layer._leaflet_id
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
      feature = leafletEvent.leafletEvent.popup.options.feature;
      if feature.mode == 'show'
        newScope = $scope.$new()
        newScope.feature = feature.properties
        $compile(leafletEvent.leafletEvent.popup._contentNode)(newScope)

      return
    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      console.log leafletEvent
      return
    return
]
