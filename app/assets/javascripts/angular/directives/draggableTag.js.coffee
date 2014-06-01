angular.module("DialogMapApp").directive 'draggableTag', [ 'editable.dragHelperService', (drag) ->
  restrict: 'C'
  link: (scope, element, attrs) ->
    console.log scope
    element.attr('contenteditable', false)
    element[0].addEventListener 'dragstart', (event) ->
      dragData = {}
      if scope.tag._leaflet_id?
        dragData =
          _leaflet_id: scope.tag.leaflet_id
          options: scope.tag.options
      event.dataTransfer.effectAllowed = 'move'
      event.dataTransfer.setData 'reference/feature', JSON.stringify dragData
      #event.dataTransfer.setData 'text/html', '<span ng-include="\'draggable-tag.html\'"></span>'
      event.dataTransfer.setData 'text/html', element[0].outerHTML
      true

    return
]
