angular.module("SustainabilityApp").directive 'contributionInput', ->
  restrict: 'AE'
  require: '^MapController'
  templateUrl: 'contribution_input.html'
