angular.module("SustainabilityApp").directive 'descriptionArea', [
  'Contribution'
  'leafletData'
  'descriptionTagHelper'
  (Contribution, leafletData, descriptionTagHelper) ->
    restrict: 'AE'
    require: 'ngModel'
    transclude: true
    scope: { ngModel: '=ngModel' }
    templateUrl: 'descriptionarea.html'
    link: (scope, element, attrs, controller) ->
      angular.extend scope,
        internal: {}
        clickMarker: (e) ->
          Contribution.startAddMarker()
          replaceSelectedText(scope.selection, 'marker', 'feature')
          disableDescriptionArea()
          return
        clickPolygon: (e) ->
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
          element.find("[type_id=#{id}][type=#{type}]").remove()
          enableDescriptionArea()
          return
        clickFeatureReference: ->
          Contribution.startAddFeatureReference()
          replaceSelectedText(scope.selection, 'reference', 'feature_reference')
          disableDescriptionArea()
          return
        clickUrlReference: ->

          return

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
        return

      replaceSelectedText = (replacementText, icon_type, box_type) ->
        #store the contents in case the user aborts
        scope.old_contents = element.find('#contribution_description_text').html()
        if window.getSelection
          sel = window.getSelection()
          if sel.rangeCount
            range = sel.getRangeAt(0)
            range.deleteContents()
            range.insertNode descriptionTagHelper.createReplacementNode(replacementText, icon_type, box_type, scope.clickDelete)
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
        element.find(".contributions-buttons").show().css("left", x).css("top", y)
        return

      hideButtons = ->
        element.find(".contributions-buttons").hide()

      element.find('#contribution_description_text').on 'mouseup', (e) ->
        scope.selection = getSelection()
        if scope.selection != ""
          # calculate the position of the toolbar..
          parentOffset = angular.element('#sidebar').offset()
          relX = e.pageX - parentOffset.left
          relY = e.pageY - parentOffset.top
          lineHeight = parseInt(element.find('#contribution_description_text').css('line-height'))
          showButtons(relX, relY + lineHeight / 2  )
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
        element.find('#contribution_description_text').html('')
        return

      # finally update the description
      scope.$on 'Contribution.submit_start', (e) ->
        updateExternalDescription()
        return

      return
]
