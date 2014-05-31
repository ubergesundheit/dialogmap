angular.module('SustainabilityApp').factory 'Contribution', [
  'railsResourceFactory'
  'leafletData'
  '$rootScope'
  'contributionTransformer'
  'User'
  '$queue'
  (railsResourceFactory, leafletData, $rootScope, contributionTransformer, User, $queue) ->
    resource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'

    queueCallback = (item) ->
      item.childrenContributions.map (i) ->
        found = false
        (angular.extend(i,contrib); found = true) for contrib in resource.all_contributions when contrib.id is i.id
        if found == false
          resource.get({id: i.id}).then (contrib) ->
            angular.extend(i,contrib)
            # _populateChildrenQueue.add(i)
            return
      return
    # create a Queue for popuplating the children in the all_contributions array
    _populateChildrenQueue = $queue.queue queueCallback, { paused: true, complete: -> @.pause(); _buildTree(); return }


    resource.all_contributions = []

    resource.parent_contributions = []

    _buildTree = ->
      resource.parent_contributions = []
      resource.parent_contributions.push c for c in resource.all_contributions when !c.parentId?
      resource.setCurrentContribution(resource.currentContribution.id) if resource.currentContribution?
      return

    _updateParentInAllContributions = (contribution) ->
      hasChild = (parent, childId) ->
        found = false
        (found = true) for child in parent.childrenContributions when child.id is childId
        found

      for parent in resource.all_contributions when parent.id is contribution.parentId
        if !hasChild(parent, contribution.id)
          parent.childrenContributions.push contribution
      return

    resource.addInterceptor
      response: (result, resourceConstructor, context) ->
        console.log 'interceptor start'
        # transform all incoming contributions into fancy contributions. uuh!
        # make sure the resultData is always an array
        if angular.isArray(result.data) then resultData = result.data else resultData = [result.data]

        (resource.all_contributions.push contributionTransformer.createFancyContributionFromRaw(c)
        _populateChildrenQueue.add c
        _updateParentInAllContributions(c)) for c in resultData when c.id not in resource.all_contributions.map (r) -> r.id
        _populateChildrenQueue.start()
        console.log 'interceptor end'
        result

    resource.currentContribution = undefined

    # Methods for Contribution collection
    resource.setCurrentContribution = (id) ->
      resource.currentContribution = undefined
      found = false
      (resource.currentContribution = elem; found = true) for elem in resource.all_contributions when elem.id is parseInt(id)
      if found == false
        resource.get({id: id}).then (data) ->
          resource.setCurrentContribution(id)
          return

      return

    $rootScope.$on '$stateChangeSuccess', (event, toState, toParams) ->
      if toState.name is 'contribution'
        resource.setCurrentContribution(toParams.id)

    # Methods for creating a Contribution
    resource.composing =  false
    resource.addingFeatureReference = false
    resource.references = []
    resource.features = {}
    resource.parent_contribution = undefined
    resource._currentDrawHandler = undefined

    resource.start = (parent_id) ->
      $rootScope.$broadcast('Contribution.start')
      @reset()
      if parent_id?
        @parent_contribution = parent_id
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

    resource.get()

    resource
]
