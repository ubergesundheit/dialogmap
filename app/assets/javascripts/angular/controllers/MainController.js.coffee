angular.module("SustainabilityApp").controller "MainController", [
  "$scope"
  "$compile"
  "Contribution"
  "Auth"
  "ngDialog"
  ($scope, $compile, Contribution, Auth, ngDialog) ->
    angular.extend $scope,
      loginCredentials: {}
      performLogin: ->
        Auth.login
          email: $scope.loginCredentials.email
          password: $scope.loginCredentials.password
        .then (user) ->
          $scope.loginCredentials = {}
          $scope.user =
            email: user.email
          $scope.authenticated = Auth.isAuthenticated()
          console.log user
          return
        return
      performLogout: ->
        Auth.logout().then ->
          $scope.user = undefined
          $scope.authenticated = Auth.isAuthenticated()
          return
    return
]
