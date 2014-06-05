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

      highlightRelated: (feature_id) ->
        $rootScope.$broadcast('highlightFeature', { feature_id: feature_id } )
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

    return
]
