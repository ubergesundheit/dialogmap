angular.module("DialogMapApp").controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  "$rootScope"
  ($scope, leafletData, Contribution, $rootScope) ->
    # use of L.activearea plugin in order to set the vieport to the visible area
    leafletData.getMap('map_main').then (map) ->
      map.setActiveArea
        position: "absolute"
        top: "0"
        bottom: "0"
        left: "0"
        width: "75%"
      return
    angular.extend $scope,
      Contribution: Contribution
      # layer for highlights
      highlightsLayer: L.layerGroup()
      clearHighlights: (evt, data) ->
        leafletData.getMap('map_main').then (map) ->
          # called by the mouseout of the geojson..
          if evt? and evt.type? and evt.type is 'mouseout'
            map.geojson_layer.resetStyle(evt.target)
            $scope.highlightsLayer.clearLayers()
            $rootScope.$broadcast 'resetHighlightFromMap', { feature_id: evt.target.feature.id }
          else
            (map.geojson_layer.resetStyle(f); break) for f in map.geojson_layer.getLayers() when f.feature.id is data.feature_id
            $scope.highlightsLayer.clearLayers()
          return
        return
      highlightFeature: (evt, data) ->
        # event is a leaflet Event
        leafletData.getMap('map_main').then (map) ->
          if !data?
            highlightFeature = evt.target
            # also send an event to highlight the corresponding description tag
            $rootScope.$broadcast 'highlightFeatureFromMap', { feature_id: highlightFeature.feature.id }
          else # event is a angular event
            # find the layer to highlight..
            (highlightFeature = f; break) for f in map.geojson_layer.getLayers() when f.feature.id is data.feature_id

          if  highlightFeature instanceof L.Polygon
            highlightFeature.setStyle
              weight: 6
              color: 'orange'
              fillOpacity: 0.7
          else # the feature is a Marker..
            highlightCircle = L.circleMarker(highlightFeature.getLatLng(), { radius: 20, className: 'highlight' })
            $scope.highlightsLayer.addLayer(highlightCircle)
          return
        return

      # leaflet-directive stuff
      muenster:
        lat: 51.96
        lng: 7.62
        zoom: 14
      controls:
        draw: true
      events:
        map:
          enable: ['moveend','draw:created','click','popupopen']
          logic: 'emit'
      tiles:
        url: '//osm-bright-ms.herokuapp.com/v2/osmbright/{z}/{x}/{y}.png'
      # contains all geofeatures
      geojson:
        data: { "type": "FeatureCollection", "features": [] }
        style: L.mapbox.simplestyle.style
        pointToLayer: L.mapbox.marker.style
        onEachFeature: (feature, layer) ->
          layer.bindPopup L.mapbox.marker.createPopup(feature),
            closeButton: false
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

      updateGeoJSON: (skip_reload, bbox_string) ->
        updateGeoJSONinScope = ->
          includeChildren = $scope.$state.is 'contribution'
          # decide which source to use
          if Contribution.currentContribution?
            contributions = [Contribution.currentContribution]
          else if Contribution.parent_contributions?
            contributions = Contribution.parent_contributions

          # transform the array to a feature collection
          fCollection =
            type: 'FeatureCollection'
            features: []
          pushFeaturesToCollection = (features) ->
            for f in features
              do ->
                fCollection.features.push f
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
          $scope.geojson =
            style: $scope.geojson.style
            onEachFeature: $scope.geojson.onEachFeature
            pointToLayer: $scope.geojson.pointToLayer
            data: fCollection
          return

        if !skip_reload? #reload the map!
          Contribution.query({bbox: bbox_string}).then  ->
            updateGeoJSONinScope()
            return
        else
          updateGeoJSONinScope()
          $scope._dataFresh = true
        return

      removeDraftFeature: (leaflet_id) ->
        $scope.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        return

    # init stuff
    $scope.$on 'Contribution.submitted', (evt, data) ->
      $scope.updateGeoJSON(true)
      return

    $scope.$on 'leafletDirectiveMap.moveend', (evt, leafletEvent) ->
      if $scope.$state.is 'contributions'
        bbox_string = leafletEvent.leafletEvent.target.getBounds().pad(1.005).toBBoxString()
        $scope.updateGeoJSON(undefined,bbox_string)
      return

    # $scope.$on '$stateChangeSuccess', (event, toState, toParams) ->
    #     $scope.updateGeoJSON(true) # update the map to only show marker from the selected topic
    #   return

    $scope.$on '$stateChangeSuccess', (event, toState, toParams) ->
      $scope._dataFresh = (toState.name == 'contributions')
        # $scope.updateGeoJSON(true) # update the map to only show marker from the selected topic
      return

    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      #console.log leafletEvent
      return

    $scope.$watch "Contribution.currentContribution", (data) ->
      $scope.updateGeoJSON(data) # update the map to only show marker from the selected topic
      return

    $scope.$watch "geojson.data", (data) ->
      if $scope._dataFresh == true
        if data.features and data.features.length > 0
          leafletData.getMap('map_main').then (map) ->
            bounds = L.geoJson(data).getBounds()
            map.fitBounds(bounds, { maxZoom: 17, padding: [50,50]})
            $scope._dataFresh = false
            return
      return

    $scope.$on 'highlightFeature', $scope.highlightFeature

    $scope.$on 'resetHighlightFeature', $scope.clearHighlights

    # add a layer for highlighting features to the map..
    leafletData.getMap('map_main').then (map) ->
      $scope.highlightsLayer.addTo(map)
      return

]
