angular.module('DialogMapApp').factory 'Contribution', [
  'railsResourceFactory'
  'leafletData'
  '$rootScope'
  'contributionTransformer'
  'User'
  '$state'
  '$q'
  'propertiesHelper'
  'contributionFilterService'
  (railsResourceFactory, leafletData, $rootScope, contributionTransformer, User, $state, $q, propertiesHelper, contributionFilterService) ->
    resource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'


    resource.getContribution = (id) ->
      contribution = $q.defer()
      found = false
      id = parseInt(id) if id?
      (contribution.resolve(elem); found = true; break) for elem in resource.parent_contributions when elem.id is id
      if found == false
        # search the whole tree...
        for parent in resource.parent_contributions
          (contribution.resolve(child); found = true; break) for child in parent.childContributions when child.id is id

        # if all fails.. fetch the missing contribution/s
        # the interceptor will take care of appending it to the correct parent
        # and making the contribution fancy
        if found == false
          resource.get(id).then contribution.resolve
      contribution.promise

    resource.parent_contributions = []
    resource.display_contributions = []

    _replaceOrAppendContribution = (contribution) ->
      # update the tree
      if !contribution.parentId? # the contribution is a topic/parent
        replaced = false
        for elem,i in resource.parent_contributions
          if elem.id is contribution.id
            resource.parent_contributions[i] = contribution
            replaced = true
            break
        unless replaced
          resource.parent_contributions.push contribution
      else
        # search for the parent and replace/append in its childContributions
        for parent in resource.parent_contributions
          if parent.id is contribution.parentId
            replaced = false
            for child, i in parent.childContributions
              if child.id is contribution.id
                parent.childContributions[i] = contribution
                replaced = true
                break
            unless replaced
              parent.childContributions.push contribution
      # also update the current Contribution
      if resource.currentContribution?
        resource.setCurrentContribution(resource.currentContribution.id)
      return

    resource.addInterceptor
      response: (result, resourceConstructor, context) ->
        # make sure the resultData is always an array
        if angular.isArray(result.data) then resultData = result.data else resultData = [result.data]

        ( _replaceOrAppendContribution(c) )for c in resultData

        # apply the filters, prepare the display_contributions
        contributionFilterService.applyFilter resource.parent_contributions, (contributions) ->
          resource.display_contributions = contributions
          return

        # only update the map here if the network call was for the index (not /api/contributions/:id)
        if !result.config.url.match(/\/api\/contributions\/\d+/) or !resource.currentContribution?
          $rootScope.$broadcast 'map.updateFeatures',
            contributions: resource.display_contributions,
            focusFeatures: !(result.config.params? and result.config.params.bbox?)

        result

    resource.currentContribution = undefined

    resource.setCurrentContribution = (id) ->
      resource.getContribution(id).then (contribution) ->
        resource.currentContribution = contribution
        $rootScope.$broadcast('map.updateFeatures', { contributions: [resource.currentContribution], includeChildren: true, focusFeatures: true})
        return
      return

    # Methods for Contribution collection
    resource.fetchAndSetCurrentContribution = (id) ->
      resource.get({id: id}).then ->
        resource.setCurrentContribution(id)
        return
      return

    # Methods for creating a Contribution
    resource.composing =  false
    resource.editing = false
    resource.isAnswer = false
    resource.addingFeatureReference = false
    resource.references = []
    resource.features = {}
    resource.parent_contribution = undefined
    resource._currentDrawHandler = undefined
    resource.category = ""
    resource.activity = ""
    resource.content = []

    resource.setContributionForEdit = (id) ->
      resource.getContribution(id).then (contrib) ->
        angular.extend resource, contrib
        resource.threadStartEditing = true unless contrib.parentId?
        resource.editing = true
        return
      return

    resource.start = (parent_id) ->
      $rootScope.$broadcast('Contribution.start')
      @reset()
      if parent_id?
        @parent_contribution = parent_id
        resource.getContribution(parent_id).then (parent) ->
          resource.category = parent.category
          resource.activity = parent.activity
          resource.content = parent.content
          return
      @composing = true
      return
    resource.startAnswer = (parent_id) ->
      @start(parent_id)
      @isAnswer = true
    resource.addFeature = (feature) ->
      @features[feature] = {}
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.enableEditing()
        return
      return
    resource.removeFeature = (leaflet_id) ->
      @features = Object.keys(@features).filter (feature) -> feature isnt parseInt(leaflet_id)
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.getLayer(leaflet_id).disableEditing()
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
        category = (if resource.category? then resource.category else { color: "#7e7e7e" })
        activity = (if resource.activity? then resource.activity else { icon: "circle-stroked"})
        resource._currentDrawHandler = new L.Draw.Marker(map, { icon: L.mapbox.marker.icon(propertiesHelper.createProperties('','Point',category.color, activity.icon))})
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
    resource.resetDates = ->
      @startDate = undefined
      @endDate = undefined
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
      @references_attributes = undefined
      @references = []
      @features_attributes = undefined
      @features = {}
      @id = undefined
      @parent_contribution = undefined
      @category = ""
      @activity = ""
      @content = []
      @isAnswer = false
      @threadStartEditing = undefined
      @editing = false
      @resetDates()
      @errors = undefined
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.disableEditing()
        map.drawControl.options.edit.featureGroup.clearLayers()
        return
      @disableDraw()
      return
    resource.submit = ->
      if User.isAuthenticated()
        $rootScope.$broadcast('Contribution.submit_start')
        if contributionTransformer.validateContribution(@)
          # this is a defered because the method internally uses the map which
          # is fetched by a deferred
          contributionTransformer.createContributionForSubmit(@).then (contribution) ->
            if resource.id?
              # update
              contribution.id = resource.id
              contribution.parent_id = resource.parentId
              new resource(contribution).update().then (data) ->
                $rootScope.$broadcast('Contribution.submitted', data)
                return
              resource.abort()
              return
            else
              resource.abort()
              new resource(contribution).create().then (data) ->
                $rootScope.$broadcast('Contribution.submitted', data)
                return
              return
      else
        User._unauthorized()
      return
    resource.disable = (id, reason) ->
      if User.isAuthenticated()
        new resource({id: id, deleted: true, delete_reason: reason}).update()
      else
        User._unauthorized()
      return

    updateFeatures = (value) ->
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.eachLayer (l) ->
          if l._icon?
            category = (if resource.category? then resource.category else { color: "#7e7e7e" })
            activity = (if resource.activity? then resource.activity else { icon: "circle-stroked"})
            l.setIcon L.mapbox.marker.icon(propertiesHelper.createProperties('','Point',category.color, activity.icon))
            icon = l._icon
            icon.style.display = "none"
            if L.DomUtil.hasClass(icon, "leaflet-edit-marker-selected")
              L.DomUtil.removeClass icon, "leaflet-edit-marker-selected"

              # Offset as the border will make the icon move.
              iconMarginTop = parseInt(icon.style.marginTop, 10) + 4
              iconMarginLeft = parseInt(icon.style.marginLeft, 10) + 4
              icon.style.marginTop = iconMarginTop + "px"
              icon.style.marginLeft = iconMarginLeft + "px"
            else
              L.DomUtil.addClass icon, "leaflet-edit-marker-selected"

              # Offset as the border will make the icon move.
              iconMarginTop = parseInt(icon.style.marginTop, 10) - 4
              iconMarginLeft = parseInt(icon.style.marginLeft, 10) - 4
              icon.style.marginTop = iconMarginTop + "px"
              icon.style.marginLeft = iconMarginLeft + "px"
            icon.style.display = ""
          return
        return
      return

    $rootScope.$watch(
      -> resource.category
      updateFeatures
    )

    $rootScope.$watch(
      -> resource.activity
      updateFeatures
    )

    resource
]
