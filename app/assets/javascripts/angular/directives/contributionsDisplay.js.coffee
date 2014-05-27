angular.module("SustainabilityApp")
.directive 'contributionsDisplay', [
  '$compile'
  'Contribution'
  ($compile, Contribution) ->
    restrict: 'AE'
    require: 'ngModel'
    replace: true
    scope: { contributions: '=ngModel' }
    templateUrl: 'contributions_show.html'
    link: (scope, element, attrs, controller) ->
      angular.extend scope,
        Contribution: Contribution
        # contributions: scope.Contribution.contributions
        startContributionHere: (id, $index) ->
          element.find('.composing_container').html('')
          inputAreaHtml = $compile("<div ng-include=\"'contribution_input.html'\"></div>")(scope)
          element.find('.contribution_input_replace:eq('+$index+')').find('.composing_container').html(inputAreaHtml)
          scope.Contribution.start(id)
          return

      return
]

.directive "contributions", ->
  restrict: "E"
  replace: true
  scope:
    contributions: "="
  templateUrl: 'contributions_show.html'
  # template: "<ul><contribution ng-repeat='contribution in contributions' contribution='contribution'></contribution></ul>"

.directive "contribution", [
  "$compile"
  "Contribution"
  ($compile, Contribution) ->
    restrict: "E"
    replace: true
    scope:
      contribution: "="
    #template: "<li>{{contribution.id}}</li>"
    templateUrl: 'contribution_show.html'
    link: (scope, element, attrs) ->
      angular.extend scope,
        Contribution: Contribution
        # contributions: scope.Contribution.contributions
        startContributionHere: (id, $index) ->
          console.log element.find('.composing_container')
          element.find('.composing_container').html('')

          inputAreaHtml = $compile("<div ng-include=\"'contribution_input.html'\"></div>")(scope)
          element.find('.contribution_input_replace:eq('+$index+')').find('.composing_container').html(inputAreaHtml)
          scope.Contribution.start(id)
          return

      if angular.isArray(scope.contribution.childrenContributions)
        element.append "<contributions contributions='contribution.childrenContributions'></contributions>"
        $compile(element.contents()) scope

      return
]
