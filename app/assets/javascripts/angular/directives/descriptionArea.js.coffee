angular.module("SustainabilityApp").directive 'descriptionArea', [
  'Contribution'
  'leafletData'
  'descriptionTagHelper'
  '$compile'
  (Contribution, leafletData, descriptionTagHelper, $compile) ->
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
          replaceSelectedText(scope.selection, 'marker')
          startFeatureCreation()
          return
        clickPolygon: (e) ->
          replaceSelectedText(scope.selection, 'polygon')
          Contribution.startAddPolygon()
          startFeatureCreation()
          return
        clickDelete: (e) ->
          leaflet_id = e.target.getAttribute('leaflet_id')
          Contribution.removeFeature(leaflet_id)
          Contribution.disableDraw()
          element.find("[leaflet_id=#{leaflet_id}]").remove()
          stopFeatureCreation()
          return

      leafletData.getMap('map_main').then (map) ->
        map.on 'draw:created', (e) ->
          e.layer.options.properties = {}
          Contribution.addFeature e.layer._leaflet_id
          # update the tag in the description field
          element.find('[leaflet_id=new]').attr('leaflet_id', e.layer._leaflet_id)
          stopFeatureCreation()
          hideButtons()
          return
        map.on 'draw:aborted', (e) ->
          stopFeatureCreation()
          # reset input to previous state
          element.find('#contribution_description_text').html(scope.old_contents)
          updateExternalDescription()
          hideButtons()
          return
        return

      startFeatureCreation = ->
        ((element.find('#contribution_description_text'))
          .attr('contenteditable', false)
          .addClass('disabled_contenteditable')
          )
        hideButtons()
        return

      stopFeatureCreation = ->
        ((element.find('#contribution_description_text'))
          .attr('contenteditable', true)
          .removeClass('disabled_contenteditable')
          )
        updateExternalDescription()
        return

      replaceSelectedText = (replacementText, type) ->
        #store the contents in case the user aborts
        scope.old_contents = element.find('#contribution_description_text').html()
        if window.getSelection
          sel = window.getSelection()
          if sel.rangeCount
            range = sel.getRangeAt(0)
            range.deleteContents()
            #range.insertNode document.createTextNode(replacementText)
            range.insertNode descriptionTagHelper.createReplacementNode(replacementText, type, scope.clickDelete)
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
          parentOffset = element.parent().offset()
          lineHeight = parseInt(element.find('#contribution_description_text').css('line-height'))
          relX = e.pageX - parentOffset.left
          relY = e.pageY - parentOffset.top
          showButtons(relX, relY + lineHeight / 2)
        else
          hideButtons()
        return

      scope.$watch 'internal.description', (value) ->
        #updateExternalDescription()
        Contribution.description = element.find('#contribution_description_text').html()
        return

      scope.$on 'Contribution.reset', (e) ->
        scope.internal.description = ''
        element.find('#contribution_description_text').html('')
        return
      # scope.removeDraftFeature = ->
      #   console.log 'implement me!!!'
      # scope.$watch 'internal.raw_description', (value) ->
      #   highlighted = ''
      #   if value? and value != ""
      #     highlighted = value.replace(/\n/g, '<br />')
      #     angular.forEach scope.references, (h) ->
      #       highlighted = highlighted.replace new RegExp("\\b(#{h.type})\\b"), (matched) ->
      #         "<span class=\"highlight\">#{matched}</span>"
      #       return
      #   element.find('.highlighter').html(highlighted)
      #   element.find('textarea.txt').html(value)
      #   scope.descr = value
      #   return
      return
]
