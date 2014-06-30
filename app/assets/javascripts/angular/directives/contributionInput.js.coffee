angular.module("DialogMapApp").directive 'contributionInput', [
  "User"
  "Contribution"
  (User, Contribution) ->
    restrict: 'AE'
    scope: { contributionInput: "=contributionInput" }
    templateUrl: 'contribution_input.html'
    controller: ($scope, $element) ->
      $scope.showDatefields = (Contribution.startDate isnt null and Contribution.startDate isnt '')
      return
    link: (scope, element, attr, controller) ->
      angular.extend scope,
        User: User
        Contribution: Contribution
        thisContribution: scope.contributionInput

        startThisContributionEdit: ->
          scope.Contribution.start()
          scope.thisContribution.composing = true
          return
        abort: ->
          scope.Contribution.abort()
          scope.thisContribution.composing = false
          return
      return
]
