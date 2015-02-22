angular.module("DialogMapApp").controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  "$rootScope"
  "$timeout"
  ($scope, leafletData, Contribution, $rootScope, $timeout) ->
    # use of L.activearea plugin in order to set the vieport to the visible area
    leafletData.getMap('map_main').then (map) ->
      map.setActiveArea
        position: "absolute"
        top: "0"
        bottom: "0"
        left: "0"
        width: "calc(100% - 450px)"
      return
    angular.extend $scope,
      Contribution: Contribution
      # layer for highlights
      highlightsLayer: L.layerGroup()
      clearHighlights: (evt, data) ->
        leafletData.getMap('map_main').then (map) ->
          # called by the mouseout of the geojson..
          if evt? and evt.type? and evt.type is 'mouseout'
            map.closePopup()
            map.geojson_layer.resetStyle(evt.target)
            $scope.highlightsLayer.clearLayers()
            $rootScope.$broadcast 'resetHighlight'
          else
            map.geojson_layer.eachLayer (f) ->
              map.geojson_layer.resetStyle f
              f.closePopup()
            $scope.highlightsLayer.clearLayers()
          return
        return
      highlightFeature: (evt, data) ->
        # event is a leaflet Event
        leafletData.getMap('map_main').then (map) ->
          if !data?
            highlightFeature = evt.target
            # also send an event to highlight the corresponding description tag
            $rootScope.$broadcast 'highlightFeature', { feature_id: highlightFeature.feature.id, contribution_id: highlightFeature.feature.properties.contributionId }
          else # event is a angular event
            # find the layer to highlight..
            (highlightFeature = f; break) for f in map.geojson_layer.getLayers() when f.feature.id is data.feature_id

          if highlightFeature instanceof L.Polygon
            highlightFeature.setStyle
              weight: 6
              color: 'orange'
              fillOpacity: 0.7
          else # the feature is a Marker..
            highlightCircle = L.circleMarker(highlightFeature.getLatLng(), { radius: 20, className: 'highlight' })
            $scope.highlightsLayer.addLayer(highlightCircle)
          highlightFeature.openPopup()
          return
        return

      # leaflet-directive stuff
      defaults:
        minZoom: 6
      controls:
        draw: true
      events:
        map:
          enable: ['moveend','draw:created','click','popupopen']
          logic: 'emit'
      tiles:
        url: 'http://tile.openstreetmap.org/{z}/{x}/{y}.png'
      # contains all geofeatures
      geojson:
        data: { "type": "FeatureCollection", "features": [] }
        style: L.mapbox.simplestyle.style
        pointToLayer: L.mapbox.marker.style
        onEachFeature: (feature, layer) ->
          layer.bindPopup L.mapbox.marker.createPopup(feature),
            closeButton: false
            autoPan: false
          layer.on 'mouseover', $scope.highlightFeature
          layer.on 'mouseout', $scope.clearHighlights
          layer.on 'click', (evt) ->
            if Contribution.addingFeatureReference == true
              feature = evt.target.feature
              Contribution.addFeatureReference feature
            else if $scope.$state.is 'contributions'
              $scope.$state.go 'contribution',
                id: evt.target.feature.properties.contributionId
            return
          return
      _dataFresh: true

      updateGeoJSONFromData: (contributions, includeChildren, focusFeatures) ->
        # transform the array to a feature collection
        fCollection =
          type: 'FeatureCollection'
          features: []
        pushFeaturesToCollection = (features) ->
          for f in features
            do ->
              fCollection.features.push f if f.id not in fCollection.features.map (x) -> x.id
              return
        for contribution in contributions
          do ->
            # add the parents features to the map..
            if contribution.features.length > 0
              pushFeaturesToCollection contribution.features

            # add the features of the children to to the map
            if includeChildren and contribution.childContributions?
              for child in contribution.childContributions
                do ->
                  if child.features.length > 0
                    pushFeaturesToCollection child.features
                  return

            return
        # Update the scope
        if !angular.equals($scope.geojson.data, fCollection)
          $scope.geojson =
            style: $scope.geojson.style
            onEachFeature: $scope.geojson.onEachFeature
            pointToLayer: $scope.geojson.pointToLayer
            data: fCollection

          if focusFeatures == true
            $timeout ->
              leafletData.getMap('map_main').then (map) ->
                bounds = L.geoJson($scope.geojson.data).getBounds()
                map.fitBounds(bounds, { maxZoom: 17, padding: [55,55]}) if Object.keys(bounds).length isnt 0
                return
              return
            ,500
            ,false

        return

      removeDraftFeature: (leaflet_id) ->
        $scope.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        return

    # init stuff
    $scope.$on 'map.updateFeatures', (evt, data) ->
      $scope.updateGeoJSONFromData(data.contributions, data.includeChildren, data.focusFeatures)
      return

    $scope.$on 'leafletDirectiveMap.moveend', (evt, leafletEvent) ->
      if $scope.$state.is 'contributions'
        bbox_string = leafletEvent.leafletEvent.target.getBounds().pad(1.005).toBBoxString()
        Contribution.query({bbox: bbox_string})
      return

    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      #console.log leafletEvent
      return

    $scope.$on 'highlightFeature', $scope.highlightFeature

    $scope.$on 'resetHighlight', $scope.clearHighlights

    # add a layer for highlighting features to the map..
    leafletData.getMap('map_main').then (map) ->
      $scope.highlightsLayer.addTo(map)
      return

]
