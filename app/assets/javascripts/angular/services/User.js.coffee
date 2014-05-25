angular.module('SustainabilityApp')
.config [
  "AuthProvider"
  (AuthProvider) ->
    AuthProvider.loginPath '/api/users/sign_in.json'
    AuthProvider.logoutPath '/api/users/sign_out.json'
    AuthProvider.registerPath '/api/users.json'
    return
]
.directive "passwordMatch", ->
  require: "ngModel"
  link: (scope, elem, attrs, ctrl) ->
    firstPassword = "#" + attrs.passwordMatch
    elem.add(firstPassword).on "keyup", ->
      scope.$apply ->
        v = elem.val() is angular.element(firstPassword).val()
        ctrl.$setValidity "pwmatch", v
        return
      return
    return
.factory 'User', [
  'Auth'
  'ngDialog'
  '$rootScope'
  (Auth, ngDialog, $rootScope) ->
    _user = {}

    _user.currentUser = undefined
    _user.isAuthenticated = Auth.isAuthenticated
    _user._off = undefined
    _user._dialogOpen = false
    scope = $rootScope.$new(true)
    scope.loading = false

    _user._unauthorized = (event, xhr, deferred) ->
      scope.loading = false
      # ignore requests without credentials (fetching session from server)
      unless xhr? and Object.keys(xhr.config.data.user).length == 0
        scope.flash = (xhr? and xhr.data.error) or "Du musst Dich anmelden oder registrieren, bevor Du fortfahren kannst."
        _user.showUserModal()
      return

    handleUser = (user) ->
      scope.flash = undefined
      scope.loginCredentials = {}
      scope.registerCredentials = {}
      scope.loading = false
      scope.user =
        email: user.email
      _user.user = scope.user
      scope.authenticated = _user.isAuthenticated()
      # _user._off = $rootScope.$on 'devise:unauthorized', _user._unauthorized
      return

    handleErrors = (error) ->
      console.log error
      scope.errors = error.data.errors
      scope.loading = false
      return

    # everything inside this scope are actions and variables for the modal
    angular.extend scope,
      loginCredentials: {}
      registerCredentials: {}
      performRegister: ->
        scope.loading = true
        Auth.register
          email: @registerCredentials.email
          password: @registerCredentials.password
          password_confirmation: @registerCredentials.password_confirmation
        .then handleUser, handleErrors
        return
      performLogin: ->
        scope.loading = true
        Auth.login
          email: @loginCredentials.email
          password: @loginCredentials.password
        .then handleUser, handleErrors
        return
      performLogout: ->
        scope.loading = true
        Auth.logout().then ->
          scope.loading = false
          scope.user = undefined
          _user.user = undefined
          scope.authenticated = _user.isAuthenticated()
          return

    # show the User Modal (Login/Register/User signout)
    _user.showUserModal = ->
      unless _user._dialogOpen
        ngDialog.open
          template: 'user_modal.html'
          scope: scope
          showClose: false
      return

    _user.logout = ->
      @showUserModal()
      scope.performLogout()
      return

    # remove the flash message
    scope.$on 'ngDialog.closed', (e, $dialog) ->
      _user._dialogOpen = false
      scope.flash = undefined
      scope.loginCredentials = {}
      scope.registerCredentials = {}
      return

    scope.$on 'ngDialog.opened', (e, $dialog) ->
      _user._dialogOpen = true
      return

    # init
    Auth.currentUser().then handleUser

    _user._off = scope.$on 'devise:unauthorized', _user._unauthorized

    _user
]
