angular.module("SustainabilityApp")
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
        childrenElementAdded = false
        # contributions: scope.Contribution.contributions
        startContributionHere: (id) ->
          # remove other composing containers
          angular.element('.composing_container').remove()

          inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")(scope)
          element.append inputAreaHtml
          scope.Contribution.start(id)
          # $compile(element.contents()) scope
          return

      # scope.$watchCollection 'contribution.childrenContributions', (newValue, oldValue) ->
      #   if angular.isArray(scope.contribution.childrenContributions)
      #     console.log 'asdasd', angular.isArray(scope.contribution.childrenContributions)
      #     childrenHtml = $compile("<contributions class='contribution-list' contributions='contribution.childrenContributions'></contributions>")(scope)
      #     element.append childrenHtml
      #   return


      return
]
