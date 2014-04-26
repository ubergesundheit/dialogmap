App.controller "SidebarController", [
  "$scope"
  "Contribution"
  ($scope, Contribution) ->
    angular.extend $scope,
      start_contribution: ->
        Contribution.reset()
        return
      jottsn: Contribution.features
      title: Contribution.title
      ct: Contribution

    return
]
