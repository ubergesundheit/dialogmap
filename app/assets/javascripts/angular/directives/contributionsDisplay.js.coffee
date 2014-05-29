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
    controller: ($scope, $element) ->
      if angular.isArray($scope.contribution.childrenContributions)
        childrenHtml = "<contributions class='contribution-list' contributions='contribution.childrenContributions'></contributions>"
        console.log $element.html()
        $element.find("[data-contribution-id=#{$scope.contribution.id}]").append childrenHtml
      return
    link: (scope, element, attrs) ->
      angular.extend scope,
        Contribution: Contribution
        # contributions: scope.Contribution.contributions
        startContributionHere: (id) ->
          # remove other composing containers
          angular.element('.composing_container').remove()
          # console.log element.find('.contribution_input_replace')

          inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")(scope)
          element.append inputAreaHtml
          scope.Contribution.start(id)
          # $compile(element.contents()) scope
          return

      # if angular.isArray(scope.contribution.childrenContributions)
      #   childrenHtml = $compile("<contributions class='contribution-list' contributions='contribution.childrenContributions'></contributions>")(scope)
      #   console.log element.html()
      #   angular.element.find("[data-contribution-id=#{scope.contribution.id}]").append childrenHtml
        #element.append childrenHtml
        # element.append "<contributions contributions='contribution.childrenContributions'></contributions>"
        # $compile(element.contents()) scope


      return
]
