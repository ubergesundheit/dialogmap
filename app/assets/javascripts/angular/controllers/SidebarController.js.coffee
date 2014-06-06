angular.module("DialogMapApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  "$state"
  "$rootScope"
  ($scope, Contribution, User, $compile, $state, $rootScope) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
      startNewTopic: ->
        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element('#new-topic-container').append(inputAreaHtml)
        Contribution.start()
        return

      startContributionHere: (id) ->
        angular.element('.composing_container').remove()

        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element(".contribution_input_replace[data-id=#{id}]").append inputAreaHtml
        Contribution.start(id)
        return

      highlightRelated: (feature_id, $event) ->
        target = angular.element($event.target)
        while target.is('span')
          target = angular.element(target.parent())
        target.addClass('highlight')
        $rootScope.$broadcast('highlightFeature', { feature_id: feature_id } )
        return

      resetHighlight: ($event) ->
        target = angular.element($event.target)
        while target.is('span')
          target = angular.element(target.parent())
        target.removeClass('highlight')
        $rootScope.$broadcast('resetHighlightFeature')
        return

    $scope.$on '$stateChangeStart', (event) ->
      $scope.loading = true
      return

    $scope.$on '$stateChangeSuccess', (event) ->
      $scope.loading = false
      return

    $scope.$on '$stateChangeError', (event) ->
      $scope.loading = false
      return

    $scope.$on 'highlightFeatureFromMap', (event, data) ->
      id = data.feature_id
      angular.element(".contribution-description-tag[feature-tag=#{id}]").addClass('highlight')
      return

    $scope.$on 'resetHighlightFromMap', (event, data) ->
      id = data.feature_id
      angular.element(".contribution-description-tag[feature-tag=#{id}]").removeClass('highlight')
      return

    return
]
