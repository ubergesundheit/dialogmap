angular.module('SustainabilityApp').factory 'Contribution', [
  'railsResourceFactory'
  'leafletData'
  '$rootScope'
  (railsResourceFactory, leafletData, $rootScope) ->
    resource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'

    resource.composing =  false
    resource.addingFeature = false
    resource.references = []
    resource.features = []
    resource._setDrawControlVisibility = (onoff) ->
      leafletData.getMap('map_main').then (map) ->
        if map.options.drawControl == true and onoff == false
          map.removeControl(map.drawControl)
          map.options.drawControl = false
        else if map.options.drawControl == false and onoff == true
          map.addControl(map.drawControl)
          map.options.drawControl = true
        return
      return
    resource.start = (reference) ->
      $rootScope.$broadcast('Contribution.start')
      if reference?
        @reset()
        @addFeatureReference reference
      else
        @references = []
      @_setDrawControlVisibility(false)
      @composing = true
      return
    resource.addFeatureReference = (reference) ->
      if reference._leaflet_id?
        tempRef =
          title: ''
          #type: if reference.feature_type != 'marker' then 'polygon' else reference.feature_type
          type: 'FeatureReference'
          ref_id: reference._leaflet_id
          drawnItem: true
      else
        tempRef =
          title: if reference.geometry? then reference.properties.title
          #type: if reference.geometry.type == 'Point' then 'marker' else 'polygon'
          type: 'FeatureReference'
          ref_id: reference.id

      @references.push tempRef
      return
    resource.startAddFeatureReference = ->
      $rootScope.$broadcast('Contribution.startAddFeatureReference')
      @addingFeature = true
      @_setDrawControlVisibility(true)
      return
    resource.stopAddFeatureReference = ->
      $rootScope.$broadcast('Contribution.startAddFeatureReference')
      @addingFeature = false
      @_setDrawControlVisibility(false)
      return
    resource.abort = ->
      @reset()
      @composing = false
      @addingFeature = false
      @_setDrawControlVisibility(true)
      return
    resource.reset = ->
      @title = ''
      @description = ''
      @references = []
      @features = []
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.clearLayers()
        map.drawControl.disableEditing()
        return
      return
    resource.submit = ->
      leafletData.getMap('map_main').then (map) ->
        references_attributes = resource.references.filter (ref) -> !ref.drawnItem?
        features_attributes = ( { "geojson": feature } for feature in map.drawControl.options.edit.featureGroup.toGeoJSON().features)
        contribution =
          title: resource.title
          description: resource.description
          references_attributes: references_attributes
          features_attributes: features_attributes
        resource.abort()
        new resource(contribution).create().then (data) ->
          $rootScope.$broadcast('Contribution.submitted', data)
          return
        resource._setDrawControlVisibility(true)
        return
      return

    resource
]
# newContribution:
#   composing: false
#   addingFeature: false
#   references: []
#   start: (reference) ->
#     if reference?
#       @reset()
#       @addFeatureReference reference
#     else
#       @references = []
#     $scope.setDrawControlVisibility(false)
#     @composing = true
#     return
#   addFeatureReference: (reference) ->
#     if reference._leaflet_id?
#       tempRef =
#         title: ''
#         #type: if reference.feature_type != 'marker' then 'polygon' else reference.feature_type
#         type: 'FeatureReference'
#         ref_id: reference._leaflet_id
#         drawnItem: true
#     else
#       tempRef =
#         title: if reference.geometry? then reference.properties.title
#         #type: if reference.geometry.type == 'Point' then 'marker' else 'polygon'
#         type: 'FeatureReference'
#         ref_id: reference.id
#
#     @references.push tempRef
#     return
#   startAddFeatureReference: ->
#     @addingFeature = true
#     $scope.setDrawControlVisibility(true)
#     return
#   stopAddFeatureReference: ->
#     @addingFeature = false
#     $scope.setDrawControlVisibility(false)
#     return
#   abort: ->
#     @reset()
#     @composing = false
#     @addingFeature = false
#     $scope.setDrawControlVisibility(true)
#     return
#   reset: ->
#     @title = ''
#     @description = ''
#     @references = []
#     $scope.drawControl.options.edit.featureGroup.clearLayers()
#     $scope.drawControl.disableEditing()
#     return
#   submit: ->
#     @references_attributes = @references.filter (ref) -> !ref.drawnItem?
#     @references = undefined
#     @features_attributes = ( { "geojson": feature } for feature in $scope.drawControl.options.edit.featureGroup.toGeoJSON().features)
#     new Contribution(@).create().then (data) ->
#       temp = $scope.geojson
#       for feature in data.featuresAttributes
#         do ->
#           temp.data.features.push feature.geojson
#           return
#       $scope.geojson =
#         style: temp.style
#         onEachFeature: temp.onEachFeature
#         pointToLayer: temp.pointToLayer
#         data: temp.data
#       return
#     @reset()
#     $scope.setDrawControlVisibility(true)
#     @composing = false
#     @addingFeature = false
#     return
