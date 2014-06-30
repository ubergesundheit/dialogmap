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
      $scope.selected_time = {}
      $scope.previously_selected_categories = {}
      $scope.previously_selected_activities = {}
      $scope.previously_selected_contents = {}
      $scope.previously_selected_time = {}
      $scope.fetchFilterItems = ->
        $http.get('/api/contributions/filter_items').then (response) ->
          $scope.categories = response.data.categories
          $scope.activities = response.data.activities
          $scope.contents = response.data.contents
          return
        return
      # $scope.fetchFilterItems()
      return
    link: (scope, element, attr, controller) ->

      scope.$on '$stateChangeSuccess', scope.fetchFilterItems
      scope.$on 'Contribution.submitted', scope.fetchFilterItems

      setAndApplyFilter = (value, oldvalue, scope) ->
        categories = (k for k,v of scope.selected_categories when v == true)
        activities = (k for k,v of scope.selected_activities when v == true)
        contents = (k for k,v of scope.selected_contents when v == true)
        time = scope.selected_time.only_limited
        if categories.length isnt 0 or activities.length isnt 0 or contents.length isnt 0 or time isnt false
          contributionFilterService.setFilter({
            categories: categories
            activities: activities
            contents: contents
            time: time
          })
        else
          contributionFilterService.resetFilter()

        contributionsToFilter = Contribution.parent_contributions
        if scope.isCurrentContribution
          contributionsToFilter = [Contribution.currentContribution]

        contributionFilterService.applyFilter contributionsToFilter, scope.isCurrentContribution, (filtered_contributions) ->
          Contribution.display_contributions = filtered_contributions
          return
        return

      scope.$watchCollection 'selected_categories', setAndApplyFilter
      scope.$watchCollection 'selected_activities', setAndApplyFilter
      scope.$watchCollection 'selected_contents', setAndApplyFilter
      scope.$watchCollection 'selected_time', setAndApplyFilter

      scope.$watch 'Contribution.currentContribution', (value, oldvalue, scope) ->
        contributionFilterService.resetFilter()
        scope.isCurrentContribution = false

        current_category = {}
        current_activity = {}
        current_content = {}
        if value? # there is a currentContribution
          scope.previously_selected_categories = scope.selected_categories
          scope.previously_selected_activities = scope.selected_activities
          scope.previously_selected_contents = scope.selected_contents
          current_category[value.category.id] = true
          current_activity[value.activity.id] = true
          for content in value.content
            current_content[content.id] = true
          scope.isCurrentContribution = true
        else
          current_category = scope.previously_selected_categories
          current_activity = scope.previously_selected_activities
          current_content = scope.previously_selected_contents

        scope.selected_categories = current_category
        scope.selected_activities = current_activity
        scope.selected_contents = current_content
        return

      return
]
