angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "Auth"
  ($scope, Contribution, Auth) ->
    angular.extend $scope,
      Contribution: Contribution
    return
]
