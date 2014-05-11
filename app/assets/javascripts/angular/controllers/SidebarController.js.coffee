angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  ($scope, Contribution) ->
    angular.extend $scope,
      Contribution: Contribution
    return
]
