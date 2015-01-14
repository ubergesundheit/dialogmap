angular.module("DialogMapApp").controller "MainController", [
  "$scope"
  "ngDialog"
  "$cookies"
  "Analytics"
  ($scope, ngDialog, $cookies, Analytics) ->
    angular.extend $scope,
      showIntroOnStartup:  -> $cookies.showIntroOnStartup
      showHelpModal: (slide) ->
        $scope.actualslide = slide || 0
        ngDialog.open
          template: 'help_modal.html'
          scope: $scope
          className: 'ngdialog-theme-default help-modal'
        return
      transformAdresses: ->
        for link in angular.element('.support-adress')
          email = link.innerHTML
          link.innerHTML = "<a href=\"mailto:#{email.split('').reverse().join('')}\" rel=\"nofollow\">#{email}</a>"
        return
      toggleShowIntroOnStartup: ->
        $cookies.showIntroOnStartup = if $cookies.showIntroOnStartup is 'true' then false else true
        return
      track: (action, data) ->
        Analytics.trackEvent(action, data)
        return

    # if !$cookies.showIntroOnStartup?
    #   $cookies.showIntroOnStartup = "true"

    # if $cookies.showIntroOnStartup is "true"
    #   $scope.showHelpModal()
    return
]
