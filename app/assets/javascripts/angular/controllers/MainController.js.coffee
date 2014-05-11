angular.module("SustainabilityApp").controller "MainController", [
  "$scope"
  "$compile"
  "Contribution"
  "Auth"
  "ngDialog"
  ($scope, $compile, Contribution, Auth, ngDialog) ->
    angular.extend $scope,
      #Contribution: Contribution
      login: {}
      performLogin: ->
        console.log $scope.login
        Auth.login
          email: $scope.login.email
          password: $scope.login.password
        .then (user) ->
          console.log user
          ngDialog.close()
          return
        return
]
