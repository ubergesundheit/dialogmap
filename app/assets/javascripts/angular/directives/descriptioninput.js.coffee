angular.module("SustainabilityApp").directive 'descriptionArea', ->
  assembleDescription = (raw_str, highlights)->
    raw_str
  restrict: 'AE'
  require: 'ngModel'
  transclude: true
  scope: { descr: '=ngModel', highlights: '=highlights' }
  templateUrl: 'descriptionarea.html'
  link: (scope, element, attrs, controller) ->
    scope.$watch 'internal.raw_description', (value) ->
      highlighted = ''
      if value? and value != ""
        highlighted = value.replace(/\n/g, '<br />')
        #re = new RegExp("\\b(#{scope.highlights.join(')\\b|\\b(')})\\b","")
        angular.forEach scope.highlights, (h) ->
          highlighted = highlighted.replace new RegExp("\\b(#{h})\\b"), (matched) ->
            "<span class=\"highlight\">#{matched}</span>"
      element.find('.highlighter').html(highlighted)
      element.find('textarea.txt').html(value)
      scope.descr = assembleDescription(value, scope.highlights)
      return
