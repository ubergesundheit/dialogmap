angular.module("DialogMapApp").directive 'contributionFilter', [
  'contributionFilterService'
  'Contribution'
  '$http'
  (contributionFilterService, Contribution, $http) ->
    restrict: 'AE'
    scope: true
    templateUrl: 'contribution_filter.html'
    controller: ($scope, $element) ->
      $scope.selected_categories = {}
      $scope.selected_activities = {}
      $scope.selected_contents = {}
      $http.get('/api/contributions/categories').then (response) ->
        $scope.categories = response.data
        return
      $http.get('/api/contributions/activities').then (response) ->
        $scope.activities = response.data
        return
      $http.get('/api/contributions/contents').then (response) ->
        $scope.contents = response.data
        return
      return
    link: (scope, element, attr, controller) ->

      setAndApplyFilter = (value, oldvalue, scope) ->
        categories = (k for k,v of scope.selected_categories when v == true)
        activities = (k for k,v of scope.selected_activities when v == true)
        contents = (k for k,v of scope.selected_contents when v == true)
        if categories.length isnt 0 or activities.length isnt 0 or contents.length isnt 0
          contributionFilterService.setFilter({
            categories: categories
            activities: activities
            contents: contents
          })
        else
          contributionFilterService.resetFilter()

        contributionFilterService.applyFilter Contribution.parent_contributions, (filtered_contributions) ->
          Contribution.display_contributions = filtered_contributions
          return
        return

      scope.$watchCollection 'selected_categories', setAndApplyFilter
      scope.$watchCollection 'selected_activities', setAndApplyFilter
      scope.$watchCollection 'selected_contents', setAndApplyFilter

      return
]
