angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "$compile"
  "leafletData"
  "Contribution"
  "Auth"
  "ngDialog"
  ($scope, $compile, leafletData, Contribution, Auth, ngDialog) ->
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
          enable: ['moveend','draw:created','click','popupopen']
          logic: 'emit'
      tiles:
        url: 'http://osm-bright-ms.herokuapp.com/v2/osmbright/{z}/{x}/{y}.png'
      # contains all geofeatures
      geojson:
        data: { "type": "FeatureCollection", "features": [] }
        style: L.mapbox.simplestyle.style
        pointToLayer: L.mapbox.marker.style
        onEachFeature: (feature, layer) ->
          layer.bindPopup L.mapbox.marker.createPopup(feature),
            closeButton: false
          layer.on 'click', (evt) ->
            Contribution.setCurrentContribution(evt.target.feature.properties.contributionId)
            if Contribution.addingFeature == true
              feature = evt.target.feature
              Contribution.addFeatureReference feature
              Contribution.stopAddFeatureReference()
            return
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
              pointToLayer: $scope.geojson.pointToLayer
              data: fcollection
            return
          return
        return

      removeDraftFeature: (leaflet_id) ->
        $scope.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        return

      # Map Object use with .then (map) ->
      map_main: leafletData.getMap('map_main')
      setDrawControlVisibility: (onoff) ->
        $scope.map_main.then (map) ->
          if map.options.drawControl == true and onoff == false
            map.removeControl($scope.drawControl)
            map.options.drawControl = false
          else if map.options.drawControl == false and onoff == true
            map.addControl($scope.drawControl)
            map.options.drawControl = true
          return
        return
      Contribution: Contribution

    # init stuff
    # put the feature creation controls to the map because someone could want to create a new contribution
    # which gets started by creating a feature
    Contribution._setDrawControlVisibility(true)
    $scope.$on 'Contribution.submitted', (evt, data) ->
      temp = $scope.geojson
      for feature in data.featuresAttributes
        do ->
          feature.geojson.properties.contributionId = data.id
          temp.data.features.push feature.geojson
          return
      $scope.geojson =
        style: temp.style
        onEachFeature: temp.onEachFeature
        pointToLayer: temp.pointToLayer
        data: temp.data
      return

    $scope.$on 'leafletDirectiveMap.moveend', (evt) ->
      $scope.updateGeoJSON()
      return

    $scope.$on 'leafletDirectiveMap.draw:created', (evt,leafletEvent) ->
      if Contribution.composing == true and Contribution.addingFeature == false
        Contribution.start()
      else
        Contribution.composing = true
        Contribution.stopAddFeatureReference()

      layer = leafletEvent.leafletEvent.layer
      layer.options.properties = {}
      layer.feature_type = leafletEvent.leafletEvent.layerType

      Contribution.addFeatureReference layer

      editFeatureScope = $scope.$new()
      editFeatureScope.layer_type = leafletEvent.leafletEvent.layerType
      editFeatureScope.$watch 'popups.title', (value) ->
        ( elem.title = value ) for elem in Contribution.references when elem.ref_id? and elem.ref_id == layer._leaflet_id
        return
      editFeatureScope.$watch 'popups', (value) ->
        layer.options.properties = value
        return

      popupContent = $compile('<div popup-input="" ></div>')(editFeatureScope)
      layer.bindPopup popupContent[0],
        minWidth: 250
        feature: {}
      .openPopup()
      return

    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      #console.log leafletEvent
      return

    $scope.$watch 'Contribution.currentContribution', (value) ->
      #console.log $scope.geojson
      $scope.geojson
    return
]
