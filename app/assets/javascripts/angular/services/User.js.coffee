angular.module('SustainabilityApp').factory 'User', [
  'Auth'
  'ngDialog'
  '$rootScope'
  (Auth, ngDialog, $rootScope) ->
    _user = {}

    _user.currentUser = undefined
    _user.isAuthenticated = Auth.isAuthenticated
    scope = $rootScope.$new(true)


    handleUser = (user) ->
      scope.loginCredentials = {}
      scope.registerCredentials = {}
      scope.user =
        email: user.email
      _user.user = scope.user
      scope.authenticated = _user.isAuthenticated()
      return

    # everything inside this scope are actions and variables for the modal
    angular.extend scope,
      loginCredentials: {}
      registerCredentials: {}
      performRegister: ->
        Auth.register
          email: @registerCredentials.email
          password: @registerCredentials.password
          password_confirmation: @registerCredentials.password_confirmation
        .then handleUser
        return
      performLogin: ->
        Auth.login
          email: @loginCredentials.email
          password: @loginCredentials.password
        .then handleUser
        return
      performLogout: ->
        Auth.logout().then ->
          scope.user = undefined
          _user.user = undefined
          scope.authenticated = _user.isAuthenticated()
          return

    # show the User Modal (Login/Register/User signout)
    _user.showUserModal = ->
      ngDialog.open
        template: 'user_modal.html'
        scope: scope
      return

    _user.logout = ->
      @showUserModal()
      scope.performLogout()
      return
    # init
    Auth.currentUser().then handleUser

    _user
]
