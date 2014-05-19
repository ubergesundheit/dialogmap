angular.module('SustainabilityApp').factory 'Contribution', [
  'railsResourceFactory'
  'leafletData'
  '$rootScope'
  'propertiesHelper'
  (railsResourceFactory, leafletData, $rootScope, propertiesHelper) ->
    resource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'

    resource.contributions = []
    resource.addInterceptor
      response: (result, resourceConstructor, context) ->
        if result.status == 200
          resource.contributions = result.data
        else if result.status == 201
          console.log resource.contributions
          resource.contributions.push result.data
        result

    resource.composing =  false
    resource.addingFeature = false
    resource.references = []
    resource.features = {}
    resource._currentDrawHandler = undefined
    resource._setDrawControlVisibility = (onoff) ->
      console.log 'actually there is no draw control to toggle..'
      # leafletData.getMap('map_main').then (map) ->
      #   if map.options.drawControl == true and onoff == false
      #     map.removeControl(map.drawControl)
      #     map.options.drawControl = false
      #   else if map.options.drawControl == false and onoff == true
      #     map.addControl(map.drawControl)
      #     map.options.drawControl = true
      #   return
      return
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
      return
    resource.removeFeature = (leaflet_id) ->
      @features = Object.keys(@features).filter (feature) -> feature isnt parseInt(leaflet_id)
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.removeLayer leaflet_id
        if map.drawControl.options.edit.featureGroup.getLayers().length == 0
          map.drawControl.disableEditing();
        return
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
    resource.startAddMarker = ->
      leafletData.getMap('map_main').then (map) ->
        resource._currentDrawHandler = new L.Draw.Marker(map)
        resource._currentDrawHandler.enable()
        return
      return
    resource.startAddPolygon = ->
      leafletData.getMap('map_main').then (map) ->
        resource._currentDrawHandler = new L.Draw.Polygon(map)
        resource._currentDrawHandler.enable()
        return
      return
    resource.disableDraw = ->
      @_currentDrawHandler.disable()
      @_currentDrawHandler = undefined
      return
    resource.abort = ->
      @reset()
      @composing = false
      @addingFeature = false
      @_setDrawControlVisibility(true)
      return
    resource.reset = ->
      $rootScope.$broadcast('Contribution.reset')
      @title = ''
      @description = ''
      @references = []
      @features = {}
      leafletData.getMap('map_main').then (map) ->
        map.drawControl.options.edit.featureGroup.clearLayers()
        map.drawControl.disableEditing()
        return
      return
    resource._prepareContribution = ->
      leafletData.getMap('map_main').then (map) ->
        features_attributes = []
        descr = resource.description.replace(new RegExp(String.fromCharCode(160), "g"), " ").replace(/&nbsp;/g, " ")
        el = document.createElement('div')
        el.innerHTML = descr
        tags = Array.prototype.slice.call(el.getElementsByClassName('contribution-description-tag'))
        for tag in tags
          do ->
            l_id = tag.getAttribute('leaflet_id')
            title = tag.getElementsByClassName('tag-title')[0].innerHTML
            # create geojson from features and append some properties
            geojson = map.drawControl.options.edit.featureGroup.getLayer(l_id).toGeoJSON()
            geojson.properties = propertiesHelper.createProperties(title,geojson.geometry.type)
            features_attributes.push { geojson: geojson, leaflet_id: l_id }
            descr = descr.replace(tag.outerHTML, "%[#{l_id}]%")

        {
          title: resource.title
          description: descr.replace(/<br>$/, "")
          features_attributes: features_attributes
          references_attributes: resource.references.filter (ref) -> !ref.drawnItem?
        }
    resource.submit = ->
      @_prepareContribution().then (contribution) ->
        resource.abort()
        console.log contribution
        new resource(contribution).create().then (data) ->
          $rootScope.$broadcast('Contribution.submitted', data)
          return
      # leafletData.getMap('map_main').then (map) ->
      #   references_attributes = resource.references.filter (ref) -> !ref.drawnItem?
        # features_attributes = (
        #   (
        #     feature.properties = propertiesHelper.createProperties(0,feature.geometry.type)
        #     { "geojson": augmentFeature(feature,0) }
        #   )
        #   for feature in map.drawControl.options.edit.featureGroup.toGeoJSON().features
        #     )
        # contribution =
        #   title: resource.title
        #   description: resource._prepareDescription()
        #   references_attributes: references_attributes
        #   features_attributes: features_attributes

        #resource._setDrawControlVisibility(true)
        return
      return

    resource.setCurrentContribution = (id) ->
      ($rootScope.$apply -> resource.currentContribution = elem) for elem in resource.contributions when elem.id is id
      return

    resource
]
