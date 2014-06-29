angular.module("DialogMapApp")
# taken from http://www.bennadel.com/blog/2632-creating-asynchronous-alerts-prompts-and-confirms-in-angularjs.htm
.factory "prompt", ['$window', '$q', ($window, $q) ->
  # Define promise-based prompt() method.
  prompt = (message, defaultValue) ->
    defer = $q.defer()

    # The native prompt will return null or a string.
    response = $window.prompt(message, defaultValue)
    if response is null
      defer.reject()
    else
      defer.resolve response
    defer.promise
  prompt
]
.directive 'descriptionArea', [
  'Contribution'
  'leafletData'
  'descriptionTagHelper'
  '$compile'
  'prompt'
  (Contribution, leafletData, descriptionTagHelper, $compile, prompt) ->
    restrict: 'AE'
    require: 'ngModel'
    transclude: true
    scope: { ngModel: '=ngModel' }
    templateUrl: 'description_area.html'
    link: (scope, element, attrs, controller) ->
      angular.extend scope,
        clickMarker: (e) ->
          if e is 'bar'
            prompt('Bitte Titel des neuen Markers angeben', '').then (response) ->
              element.find('#contribution_description_text').focus()
              Contribution.startAddMarker()
              replaceSelectedText(response, 'marker', 'feature')
              disableDescriptionArea()
              return
          else
            Contribution.startAddMarker()
            replaceSelectedText(scope.selection, 'marker', 'feature')
            disableDescriptionArea()
          return
        clickPolygon: (e) ->
          if e is 'bar'
            prompt('Bitte Titel des neuen Polygons angeben', '').then (response) ->
              element.find('#contribution_description_text').focus()
              Contribution.startAddPolygon()
              replaceSelectedText(response, 'polygon', 'feature')
              disableDescriptionArea()
              return
          else
            replaceSelectedText(scope.selection, 'polygon', 'feature')
            Contribution.startAddPolygon()
            disableDescriptionArea()
          return
        clickDelete: (e) ->
          id = e.target.getAttribute('type_id')
          type = e.target.getAttribute('type')
          if type == 'feature'
            Contribution.removeFeature(id)
            Contribution.disableDraw()
          else
            Contribution.removeReference(id)
            Contribution.stopAddFeatureReference()
          element.find("[type_id=\"#{id}\"][type=#{type}]").remove()
          enableDescriptionArea()
          return
        clickFeatureReference: (e) ->
          if e is 'bar'
            prompt('Bitte Titel der neuen Vernküpfung angeben', '').then (response) ->
              element.find('#contribution_description_text').focus()
              Contribution.startAddFeatureReference()
              replaceSelectedText(response, 'reference', 'feature_reference')
              disableDescriptionArea()
              return
          else
            Contribution.startAddFeatureReference()
            replaceSelectedText(scope.selection, 'reference', 'feature_reference')
            disableDescriptionArea()
          return
        clickUrlReference: (e) ->
          if e is 'bar'
            prompt('Bitte Titel des Links angeben', '').then (response) ->
              element.find('#contribution_description_text').focus()
              replaceSelectedText(response, 'reference', 'url_reference')
              disableDescriptionArea()
              showUrlInput(getLastButtonsPos(), 'http://')
              return
          else
            disableDescriptionArea()
            replaceSelectedText(scope.selection, 'reference', 'url_reference')
            showUrlInput(getLastButtonsPos(), 'http://')
          return
        clickExistingUrlReference: (e) ->
          scope.internal.clickedUrlReference = angular.element(e.target).parent().attr('type_id')
          disableDescriptionArea()
          showUrlInput(getClickPositionWithOffset(e), decodeURIComponent(scope.internal.clickedUrlReference))
          return
        urlOnKeyEnterCallback: ($event) ->
          leaveUrlInputMode()
          $event.preventDefault()
          return

      # this should only happening if a contribution is edited..
      if scope.ngModel.description != ""
        featureReplacer = (match, offset, string) ->
          id = parseInt(match.split("").slice(2,match.length-2).join(""))
          feature = f for f in Contribution.features when f.id is id
          descriptionTagHelper
            .createNodeForEdit(id, feature.properties.title, feature.geometry.type, 'feature')
            .outerHTML

        featureReferenceReplacer = (match, offset, string) ->
          id = parseInt(match.split("").slice(2,match.length-2).join(""))
          reference = r for r in Contribution.references when r.refId is id
          descriptionTagHelper
            .createNodeForEdit(id, descriptionTagHelper.createTagTitleNodeForFeatureReference(reference), 'reference', 'feature_reference')
            .outerHTML

        urlReferenceReplacer = (match, offset, string) ->
          ref = match.split('|')
          text = decodeURIComponent(ref[1].slice(0, ref[1].length-2))
          url = decodeURIComponent(ref[0].slice(2))
          descriptionTagHelper
            .createNodeForEdit(url, text, 'reference','url_reference', scope.clickExistingUrlReference)
            .outerHTML

        transformedDescription = scope.ngModel.description

        transformedDescription = transformedDescription.replace(/%\[\d+\]%/g, featureReplacer)
        transformedDescription = transformedDescription.replace(/#\[\d+\]#/g, featureReferenceReplacer)
        transformedDescription = transformedDescription.replace(/&\[[0-9a-zA-Z-_.!~*'\(\)%]+\|[^\[&]+\]&/g, urlReferenceReplacer)

        # now make the features of this contribution editable..
        leafletData.getMap('map_main').then (map) ->
          for f in Contribution.features
            leaflet_layer = L.GeoJSON.geometryToLayer(f)

            leaflet_layer.enableEditing = ->
              if typeof leaflet_layer.editToolbar is "undefined"
                leaflet_layer.editToolbar = new L.EditToolbar.Edit(map,
                  featureGroup: L.featureGroup([leaflet_layer])
                  selectedPathOptions:
                    color: "#fe57a1"
                    opacity: 0.6
                    dashArray: "10, 10"
                    fill: not 0
                    fillColor: "#fe57a1"
                    fillOpacity: 0.1
                    maintainColor: true
                )
              leaflet_layer.editToolbar.enable()
              leaflet_layer.on("dragend", ->
                leaflet_layer.editToolbar.save()
                return
              )
              leaflet_layer.on("edit", ->
                leaflet_layer.editToolbar.save()
                return
              )

              return

            leaflet_layer.disableEditing = ->
              if leaflet_layer.editToolbar?
                leaflet_layer.editToolbar.disable()
                leaflet_layer.editToolbar = undefined
              return

            leaflet_layer._leaflet_id = f.id
            leaflet_layer.options.properties =  f.properties
            map.drawControl.options.edit.featureGroup.addLayer leaflet_layer
            map.drawControl.enableEditing()

          return

        scope.$on 'Contribution.submit_start', ->
          leafletData.getMap('map_main').then (map) ->
            map.drawControl.disableEditing()
            return
          return

        scope.$on 'Contribution.reset', ->
          leafletData.getMap('map_main').then (map) ->
            map.drawControl.disableEditing()
            return
          return

        transformedDescription = $compile("<div>#{transformedDescription}</div>")(scope)

        scope.internal =
          description: transformedDescription
        element.find('#contribution_description_text').html(transformedDescription)

        element.find('.tag-title').on 'blur keyup change', (e) ->
          parent = angular.element(e.target.parentElement)
          tag_type = parent.attr('type')
          id = parseInt(parent.attr('type_id'))
          text = e.target.childNodes[0].textContent
          if tag_type is 'feature'
            # find the feature and change the name!
            leafletData.getMap('map_main').then (map) ->
              map.drawControl.options.edit.featureGroup.eachLayer (f) ->
                if f._leaflet_id is id
                  f.options.properties.title = text
                return
              return
          else if tag_type is 'feature_reference'
            (r.title = text; break) for r in Contribution.references when r.refId is id
          return

      else
        scope.internal = {}

      # Events for Feature creation
      leafletData.getMap('map_main').then (map) ->
        map.on 'draw:created', (e) ->
          e.layer.options.properties = {}
          Contribution.addFeature e.layer._leaflet_id
          # update the tag in the description field
          element.find('[type_id=new][type=feature]').attr('type_id', e.layer._leaflet_id)
          enableDescriptionArea()
          hideButtons()
          return
        map.on 'draw:aborted', (e) ->
          enableDescriptionArea()
          # reset input to previous state
          element.find('#contribution_description_text').html(scope.old_contents)
          updateExternalDescription()
          hideButtons()
          return
        return

      #Events for FeatureReferences
      scope.$on 'Contribution.addFeatureReference', (e, data) ->
        enableDescriptionArea()
        element.find('[type_id=new][type=feature_reference]').attr('type_id', data.ref_id)
        element.find("[type_id=#{data.ref_id}][type=feature_reference]")
          .find('.tag-title')
          .append(" #{descriptionTagHelper.featureReferenceTypeIndicatorHtml(data.title, data.feature_type)}")
        return

      disableDescriptionArea = ->
        ((element.find('#contribution_description_text'))
          .attr('contenteditable', false)
          .addClass('disabled_contenteditable')
          )
        hideButtons()
        return

      enableDescriptionArea = ->
        ((element.find('#contribution_description_text'))
          .attr('contenteditable', true)
          .removeClass('disabled_contenteditable')
          )
        updateExternalDescription()
        hideUrlInput()
        return

      replaceSelectedText = (replacementText, icon_type, box_type) ->
        #store the contents in case the user aborts
        scope.old_contents = element.find('#contribution_description_text').html()
        if window.getSelection
          sel = window.getSelection()
          if sel.rangeCount
            range = sel.getRangeAt(0)
            range.deleteContents()
            range.insertNode descriptionTagHelper.createReplacementNode(replacementText, icon_type, box_type, scope.clickDelete, ( if box_type is 'url_reference' then scope.clickExistingUrlReference else undefined ))
        else if document.selection and document.selection.createRange
          range = document.selection.createRange()
          range.text = replacementText
        clearSelection()
        updateExternalDescription()
        return

      updateExternalDescription = ->
        Contribution.description = element.find('#contribution_description_text').html()
        return

      getSelection = ->
        html = ""
        unless typeof window.getSelection is "undefined"
          sel = window.getSelection()
          if sel.rangeCount
            # selection is in a tag..
            if sel.getRangeAt(0).commonAncestorContainer.parentElement?
              className = sel.getRangeAt(0).commonAncestorContainer.parentElement.className
              if className == "tag-title" or className == "tag-close"
                return ""
            container = document.createElement("div")
            i = 0

            while i < sel.rangeCount
              container.appendChild sel.getRangeAt(i).cloneContents()
              ++i
            html = container.innerHTML
        else html = document.selection.createRange().htmlText if document.selection? and document.selection.type is "Text"
        html

      clearSelection = ->
        if window.getSelection
          if window.getSelection().empty # Chrome
            window.getSelection().empty()
          # Firefox
          else window.getSelection().removeAllRanges() if window.getSelection().removeAllRanges
        # IE?
        else document.selection.empty() if document.selection
        return

      showButtons = (x,y) ->
        element.find("#floating-buttons").show().css("left", x).css("top", y)
        return

      hideButtons = ->
        elem = element.find("#floating-buttons").hide()
        return

      getLastButtonsPos = ->
        elem = element.find("#floating-buttons").hide()
        [elem.css('left'), elem.css('top')]

      showUrlInput = (x,y,text) ->
        if x instanceof Array and typeof y == 'string' and text == undefined
          element.find(".url-input").show().css("left", x[0]).css("top", x[1])
          scope.internal.clickedUrlReference = y
          element.find('#url-input-field').val(y)
          return
        element.find(".url-input").show().css("left", x).css("top", y)
        scope.internal.clickedUrlReference = text
        element.find('#url-input-field').val(text)
        return

      hideUrlInput = ->
        element.find(".url-input").hide()
        return

      popUrlInput = ->
        val = element.find('#url-input-field').val()
        element.find('#url-input-field').val('http://')
        val

      leaveUrlInputMode = ->
        urlinput = popUrlInput().trim()
        element
          .find("[type_id=\"#{encodeURIComponent(scope.internal.clickedUrlReference)}\"][type=url_reference]")
          .attr('type_id', encodeURIComponent(urlinput))
          .attr('title', urlinput.trim())
        scope.internal.clickedUrlReference = "http://"
        enableDescriptionArea()
        return

      getClickPositionWithOffset = (e) ->
        parentOffset = angular.element('#sidebar').offset()
        relX = e.pageX - parentOffset.left
        relY = e.pageY - parentOffset.top
        lineHeight = parseInt(element.find('#contribution_description_text').css('line-height'))
        [relX, relY + lineHeight / 2]

      element.find('#contribution_description_text').on 'mouseup', (e) ->
        if element.find(".url-input").is(":visible") # url input is visible..
          # user has clicked somewhere else.. leave url input mode
          leaveUrlInputMode()
        scope.selection = getSelection()
        if scope.selection != ""
          clickPos = getClickPositionWithOffset(e)
          showButtons(clickPos[0], clickPos[1])
        else
          hideButtons()
        return

      scope.$watch 'internal.description', (value) ->
        Contribution.description = element.find('#contribution_description_text').html()
        return

      # Reset the area on Contribution reset
      scope.$on 'Contribution.reset', (e) ->
        enableDescriptionArea()
        scope.internal.description = ''
        scope.internal.clickedUrlReference = undefined
        element.find('#contribution_description_text').html('')
        return

      # finally update the description
      scope.$on 'Contribution.submit_start', (e) ->
        updateExternalDescription()
        return

      return
]
