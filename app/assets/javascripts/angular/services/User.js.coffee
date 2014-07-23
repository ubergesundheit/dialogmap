angular.module('DialogMapApp')
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
  '$timeout'
  '$http'
  (Auth, ngDialog, $rootScope, $timeout, $http) ->
    _user = {}

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
      if user.confirmed is true
        scope.user =
          name: user.name
          email: user.email
          id: user.id
          external_auth: user.external_auth
        _user.user = scope.user
      else
        scope.needConfirmation = true
      scope.authenticated = user.confirmed and _user.isAuthenticated()
      return

    handleErrors = (error) ->
      console.log error
      scope.errors = error.data.errors
      scope.loading = false
      return

    handleUserEdit = ->
      scope.stopUserEdit()
      scope.performLogout()
      return

    # everything inside this scope are actions and variables for the modal
    angular.extend scope,
      loginCredentials: {}
      registerCredentials: {}
      performRegister: ->
        scope.loading = true
        Auth.register
          email: @registerCredentials.email
          name: @registerCredentials.name
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
      initSocialLogin: (provider) ->
        dualScreenLeft = (if window.screenLeft isnt `undefined` then window.screenLeft else screen.left)
        dualScreenTop = (if window.screenTop isnt `undefined` then window.screenTop else screen.top)
        width = (if window.innerWidth then window.innerWidth else (if document.documentElement.clientWidth then document.documentElement.clientWidth else screen.width))
        height = (if window.innerHeight then window.innerHeight else (if document.documentElement.clientHeight then document.documentElement.clientHeight else screen.height))
        left = ((width / 2) - (1000 / 2)) + dualScreenLeft
        top = ((height / 2) - (650 / 2)) + dualScreenTop
        socialLoginWindow = window.open(window.location.origin+"/api/users/auth/#{provider}", "socialLoginWindow", "width=1000,height=650,top=#{top},left=#{left},status=yes,scrollbars=yes,resizable=yes")
        socialLoginWindow.focus()
        # check if the window has been closed and then try to login..
        (checkLoginWindowClosed = ->
          if socialLoginWindow.closed is true
            Auth.currentUser().then handleUser
          else
            $timeout(checkLoginWindowClosed,500)
          return)()
        return
      performUpdate: ->
        scope.loading = true
        $http.put '/api/users',
          user:
            email: scope.editCredentials.email
            name: scope.editCredentials.name
            current_password: scope.editCredentials.current_password
            password: scope.editCredentials.password
            password_confirmation: scope.editCredentials.password_confirmation
        .then handleUserEdit, handleErrors
        return
      startUserEdit: ->
        scope.editCredentials =
          email: scope.user.email
          name: scope.user.name
        scope.showUserEdit = true
        return
      stopUserEdit: ->
        scope.editCredentials = {}
        scope.showUserEdit = false
        return

    # show the User Modal (Login/Register/User signout)
    _user.showUserModal = ->
      unless _user._dialogOpen
        ngDialog.open
          template: 'user_modal.html'
          scope: scope
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
      scope.needConfirmation = false
      scope.stopUserEdit()
      return

    scope.$on 'ngDialog.opened', (e, $dialog) ->
      _user._dialogOpen = true
      return

    # init
    Auth.currentUser().then handleUser

    _user._off = scope.$on 'devise:unauthorized', _user._unauthorized

    _user
]
