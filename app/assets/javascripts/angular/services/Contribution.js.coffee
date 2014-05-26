angular.module('SustainabilityApp').factory 'Contribution', [
  'railsResourceFactory'
  'leafletData'
  '$rootScope'
  'contributionTransformer'
  'User'
  (railsResourceFactory, leafletData, $rootScope, contributionTransformer, User) ->
    resource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'

    resource.contributions = []
    resource.addInterceptor
      response: (result, resourceConstructor, context) ->
        # transform the result array to fancy html
        (c = contributionTransformer.createFancyContributionFromRaw(c) for c in result.data)

        if result.status == 200
          resource.contributions = result.data
        else if result.status == 201
          # this only works if the '201-created' call returns one object
          resource.contributions.push contributionTransformer.createFancyContributionFromRaw(result.data)
        result

    resource.composing =  false
    resource.addingFeatureReference = false
    resource.references = []
    resource.features = {}
    resource.parent_contribution = undefined
    resource._currentDrawHandler = undefined

    resource.start = (reference) ->
      $rootScope.$broadcast('Contribution.start')
      if reference?
        @reset()
        @addFeatureReference reference
      else
        @references = []
      @composing = true
      return
    resource.addFeature = (feature) ->
      @features[feature] = {}
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.enableEditing()
        return
      return
    resource.removeFeature = (leaflet_id) ->
      @features = Object.keys(@features).filter (feature) -> feature isnt parseInt(leaflet_id)
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        if map.drawControl.options.edit.featureGroup.getLayers().length == 0
          map.drawControl.disableEditing()
        return
      return
    resource.addFeatureReference = (reference) ->
      resource.stopAddFeatureReference()
      tempRef =
        type: 'FeatureReference'
        title: reference.properties.title
        ref_id: reference.id
        feature_type: reference.geometry.type

      @references.push tempRef
      $rootScope.$broadcast('Contribution.addFeatureReference', tempRef)
      return
    resource.removeReference = (id) ->
      resource.references = @references.filter (f) -> f.ref_id == id
      return
    resource.startAddFeatureReference = ->
      $rootScope.$broadcast('Contribution.startAddFeatureReference')
      resource.addingFeatureReference = true
      return
    resource.stopAddFeatureReference = ->
      $rootScope.$broadcast('Contribution.stopAddFeatureReference')
      resource.addingFeatureReference = false
      return
    resource._startAddFeature = ->
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.disableEditing()
        return
      return
    resource.startAddMarker = ->
      @_startAddFeature()
      leafletData.getMap('map_main').then (map) ->
        resource._currentDrawHandler = new L.Draw.Marker(map)
        resource._currentDrawHandler.enable()
        return
      return
    resource.startAddPolygon = ->
      @_startAddFeature()
      leafletData.getMap('map_main').then (map) ->
        resource._currentDrawHandler = new L.Draw.Polygon(map)
        resource._currentDrawHandler.enable()
        return
      return
    resource.disableDraw = ->
      if @_currentDrawHandler?
        @_currentDrawHandler.disable()
        @_currentDrawHandler = undefined
      return
    resource.abort = ->
      @reset()
      @composing = false
      @addingFeatureReference = false
      return
    resource.reset = ->
      $rootScope.$broadcast('Contribution.reset')
      @title = ''
      @description = ''
      @references = []
      @features = {}
      @parent_contribution = undefined
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.disableEditing()
        map.drawControl.options.edit.featureGroup.clearLayers()
        return
      @disableDraw()
      return
    resource.submit = ->
      if User.isAuthenticated()
        $rootScope.$broadcast('Contribution.submit_start')
        contributionTransformer.createContributionForSubmit(@).then (contribution) ->
          resource.abort()
          new resource(contribution).create().then (data) ->
            $rootScope.$broadcast('Contribution.submitted', data)
            return
          return
      else
        User._unauthorized()
      return


    resource.setCurrentContribution = (id) ->
      ($rootScope.$apply -> resource.currentContribution = elem) for elem in resource.contributions when elem.id is id
      return

    resource
]
