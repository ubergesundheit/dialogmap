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
        (angular.extend(i,contrib); found = true) for contrib in resource.contributions when contrib.id is i.id
        if found == false
          resource.get({id: i.id}).then (contrib) ->
            angular.extend(i,contrib)
            return
      console.log 'callback ended for', item.id
      return
    _fetchChildrenQueue = $queue.queue queueCallback, { paused: true, complete: -> @.pause(); return }

    resource.contributions = []

    resource.addInterceptor
      response: (result, resourceConstructor, context) ->
        # transform all incoming contributions into fancy contributions. uuh!
        if result.status == 200
          (resource.contributions.push contributionTransformer.createFancyContributionFromRaw(c)
          _fetchChildrenQueue.add c) for c in result.data when c.id not in resource.contributions.map (r) -> r.id
        else if result.status == 201
          # this only works if the '201-created' call returns one object
          (resource.contributions.push contributionTransformer.createFancyContributionFromRaw(result.data)
          _fetchChildrenQueue.add result.data) unless result.data.id in resource.contributions.map (r) -> r.id
        _fetchChildrenQueue.start()
        result

    # Methods for Contribution collection
    resource.setCurrentContribution = (id) ->
      ($rootScope.$apply -> resource.currentContribution = elem) for elem in resource.contributions when elem.id is id
      return
    resource.fetchMissingReplies = (id) ->
      parent = elem for elem in resource.contributions when elem.id is id

      out_children = []

      for child in parent.childrenContributions
        do ->
          found = false
          (out_children.push contrib; found = true) for contrib in resource.contributions when contrib.id is child.id
          if found == false
            console.log ''
          return
      out_children

    resource.populateChildren = (ids) ->
      fetchChildrenQueue = $queue.queue (id) ->
        console.log 'queue', id
        # resource.get({ id: id })
        return

      fetchChildrenQueue.addEach ids

      return


    # Methods for creating a Contribution
    resource.composing =  false
    resource.addingFeatureReference = false
    resource.references = []
    resource.features = {}
    resource.parent_contribution = undefined
    resource._currentDrawHandler = undefined

    resource.start = (parent_id) ->
      console.log 'start'
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

    resource
]
