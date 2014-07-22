angular.module('DialogMapApp').service "filterItems", [
  "$http"
  "$rootScope"
  ($http, $rootScope) ->
    fetchFilterItems = ->
      $http.get('/api/contributions/filter_items').then (response) ->
        items.categories = response.data.categories
        items.activities = response.data.activities
        items.contents = response.data.contents
        return
      return

    $rootScope.$on '$stateChangeSuccess', fetchFilterItems
    $rootScope.$on 'Contribution.submitted', fetchFilterItems

    items =
      categories: []
      activites: []
      contents: []

    items
]
