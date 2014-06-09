angular.module("DialogMapApp").directive 'contributionDescription', [
  '$parse'
  '$compile'
  'contributionTransformer'
  ($parse, $compile, contributionTransformer) ->
    restrict: 'AE'
    scope: true
    link: (scope, element, attr, controller) ->
      parsed = $parse(attr.contributionDescription);
      getStringValue = ->  (parsed(scope) || '').toString()

      scope.$watch getStringValue, (value) ->
        description = parsed(scope)
        if description?
          element.html($compile(contributionTransformer.createFancyContributionDescription(description))(scope))
        else
          element.html('')
      return
]
