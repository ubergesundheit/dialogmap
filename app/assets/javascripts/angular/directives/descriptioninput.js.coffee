angular.module("SustainabilityApp").directive 'descriptionArea', ->
  restrict: 'AE'
  require: 'ngModel'
  transclude: true
  scope: { descr: '=ngModel', references: '=references' }
  templateUrl: 'descriptionarea.html'
  link: (scope, element, attrs, controller) ->
    scope.removeDraftFeature = scope.$parent.removeDraftFeature
    scope.$watch 'internal.raw_description', (value) ->
      highlighted = ''
      if value? and value != ""
        highlighted = value.replace(/\n/g, '<br />')
        angular.forEach scope.references, (h) ->
          highlighted = highlighted.replace new RegExp("\\b(#{h.type})\\b"), (matched) ->
            "<span class=\"highlight\">#{matched}</span>"
          return
      element.find('.highlighter').html(highlighted)
      element.find('textarea.txt').html(value)
      scope.descr = value
      return
    return
