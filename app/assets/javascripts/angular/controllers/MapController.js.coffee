flatten = (gj, up) ->
  switch (gj and gj.type) or null
    when "FeatureCollection"
      gj.features = gj.features.reduce((mem, feature) ->
        mem.concat flatten(feature)
      , [])
      gj
    when "Feature"
      flatten(gj.geometry).map (geom) ->
        type: "Feature"
        properties: JSON.parse(JSON.stringify(gj.properties))
        geometry: geom

    when "MultiPoint"
      gj.coordinates.map (_) ->
        type: "Point"
        coordinates: _

    when "MultiPolygon"
      gj.coordinates.map (_) ->
        type: "Polygon"
        coordinates: _

    when "MultiLineString"
      gj.coordinates.map (_) ->
        type: "LineString"
        coordinates: _

    when "GeometryCollection"
      gj.geometries
    when "Point", "Polygon", "LineString"
      [gj]
    else
      gj



angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "$compile"
  "leafletData"
  "Contribution"
  ($scope, $compile, leafletData, Contribution) ->
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
          enable: ['moveend', 'draw:created','popupopen']
          logic: 'emit'
      tiles:
        url: 'http://osm-bright-ms.herokuapp.com/v2/osmbright/{z}/{x}/{y}.png'
      #markers:
      #  $scope.drawControl.options.edit.featureGroup.eachLayer (l) ->


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
          console.log $scope.drawControl.options.edit.featureGroup.toGeoJSON()
          @features_attributes = ( { "geojson": feature } for feature in $scope.drawControl.options.edit.featureGroup.toGeoJSON().features)
          #@features_attributes = { "geojson": $scope.drawControl.options.edit.featureGroup.toGeoJSON() }
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
      id = layer._leaflet_id
      layer.options.properties = {}
      window.l = layer
      console.log layer
      popupContent = $compile('<div description-area ng_model="description_'+id+'" highlights="highlights_'+id+'"></div>')($scope)
      layer.bindPopup(popupContent[0],{minWidth: 250}).openPopup();
      $scope.$watch 'description_'+id, (value) ->
        layer.options.properties.title = value
        return
      return
    $scope.$on 'leafletDirectiveMap.popupopen', (evt, leafletEvent) ->
      #console.log $compile(leafletEvent.leafletEvent.popup._content)($scope)
    return
]
