angular.module("SustainabilityApp").controller "MapController", [
  "$scope"
  "leafletData"
  "Contribution"
  "User"
  "$state"
  ($scope, leafletData, Contribution, User, $state) ->
    angular.extend $scope,
      Contribution: Contribution
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
            if Contribution.addingFeatureReference == true
              feature = evt.target.feature
              Contribution.addFeatureReference feature
            else
              console.log evt.target.feature
              $state.go 'contribution',
                id: evt.target.feature.properties.contributionId
              # Contribution.setCurrentContribution(evt.target.feature.properties.contributionId)
            return
          return

      updateGeoJSON: (skip_reload, bbox_string) ->
        updateGeoJSONinScope = (arr) ->
          # transform the array to a feature collection
          fCollection =
            type: 'FeatureCollection'
            features: []
          for c in arr
            do ->
              if c.features.length > 0
                for f in c.features
                  do ->
                    fCollection.features.push f
                    return
              return
          # Update the scope
          $scope.geojson =
            style: $scope.geojson.style
            onEachFeature: $scope.geojson.onEachFeature
            pointToLayer: $scope.geojson.pointToLayer
            data: fCollection
          return
        if !skip_reload?
          Contribution.query({bbox: bbox_string}).then updateGeoJSONinScope
        else
          updateGeoJSONinScope(Contribution.all_contributions)
        return

      removeDraftFeature: (leaflet_id) ->
        $scope.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        return

    # init stuff
    $scope.$on 'Contribution.submitted', (evt, data) ->
      $scope.updateGeoJSON(true)
      return

    $scope.$on 'leafletDirectiveMap.moveend', (evt, leafletEvent) ->

      bbox_string = leafletEvent.leafletEvent.target.getBounds().pad(1.005).toBBoxString()
      $scope.updateGeoJSON(undefined,bbox_string)
      return

    $scope.$on 'leafletDirectiveMap.click', (evt, leafletEvent) ->
      #console.log leafletEvent
      return

]
