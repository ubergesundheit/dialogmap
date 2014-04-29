angular.module("SustainabilityApp").directive 'descriptionArea', ->
  replacements = [
    "wurst"
    "lol"
    "hello"
  ]
  restrict: 'A',
  require: 'ngModel',
  replace: true,
  scope: { ngModel: '=ngModel', highlights: '=highlights' },
  link: (scope, element, attrs, controller) ->
    scope.$watch 'ngModel', (value) ->
      if value? and value != ""
        value = value.replace(/\n/g, '<br />')
        #re = new RegExp("\\b(#{scope.highlights.join(')\\b|\\b(')})\\b","")
        angular.forEach scope.highlights, (h) ->
          value = value.replace new RegExp("\\b(#{h})\\b"), (matched) ->
            "<span class=\"highlight\">#{matched}</span>"
        #value = value.replace re, (matched) ->

      element.html(value)
      return
