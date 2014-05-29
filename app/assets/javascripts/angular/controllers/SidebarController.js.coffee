angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  ($scope, Contribution, User, $compile) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
      startNewTopic: ->
        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element('#new-topic-container').append(inputAreaHtml)
        Contribution.start()
        return
    return
]
