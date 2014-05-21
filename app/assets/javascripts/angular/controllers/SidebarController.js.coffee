angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  ($scope, Contribution, User) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
    return
]
