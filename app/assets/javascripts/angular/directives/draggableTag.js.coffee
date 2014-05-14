angular.module("SustainabilityApp").directive 'draggableTag', [ 'editable.dragHelperService', (drag) ->
  # drag.registerDropHandler({
  #     tag: 'li',
  #     types: ['text/html'],
  #     node: angular.element(''),
  #     format: (data) ->
  #       'yolo'
  # });
  restrict: 'C'
  link: (scope, element, attrs) ->
    # element[0].addEventListener(
    #   'dragstart',
    #   (e)->
    #     console.log('yea');
    #     e.dataTransfer.effectAllowed = 'move';
    #     e.dataTransfer.setData('reference', JSON.stringify({ bam: "oida"}))
    #     e.dataTransfer.setData('text/html', '<span ng-include="\'draggable-tag.html\'"></span>')
    #     #this.classList.add('drag');
    #     return false;
    #   ,
    #   false
    # );
    element.attr('contenteditable', false)
    element[0].addEventListener('dragstart', (event) ->
            if scope.$isNgContentEditable
              console.log 'isngeditable'
              drag.setDragElement(element)
              return true

            #console.log(element[0].outerHTML);
            #event.dataTransfer.setData('text/html', element[0].outerHTML);
            event.dataTransfer.effectAllowed = 'move';
            event.dataTransfer.setData('reference', JSON.stringify({ "bam": "oida"}));
            #event.dataTransfer.setData('text/html', "<span draggable=\"true\" class=\"draggable-tag\" contenteditable=\"false\" style=\"background-color:red\">wamba</span>");
            event.dataTransfer.setData('text/html', '<span ng-include="\'draggable-tag.html\'"></span>');
            return true;
        )

    # element.on 'dragstart', handleDragStart
    # element[0].on 'dragend', handleDragEnd
    return
]
