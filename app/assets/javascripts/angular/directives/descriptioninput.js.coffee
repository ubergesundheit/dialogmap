angular.module("SustainabilityApp").directive 'descriptionArea', ->
  replacements = [
    "wurst"
    "lol"
    "hello"
  ]
  restrict: 'A',
  require: 'ngModel',
  replace: true,
  scope: { ngModel: '=ngModel' },
  link: (scope, element, attrs, controller) ->
    scope.$watch 'ngModel', (value) ->
      #value = value.replace(/\s/g, '&nbsp;')
      value = value.replace(/\n/g, '<br />')
      re = new RegExp(replacements.join("|"),"gi")
      value = value.replace re, (matched) ->
        "<span class=\"highlight\">#{matched}</span>"
      element.html(value)
      return

