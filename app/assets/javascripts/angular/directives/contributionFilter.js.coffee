angular.module("DialogMapApp").directive 'contributionFilter', [
  'contributionFilterService'
  'Contribution'
  '$http'
  'filterItems'
  'Analytics'
  (contributionFilterService, Contribution, $http, filterItems, Analytics) ->
    restrict: 'AE'
    scope: true
    templateUrl: 'contribution_filter.html'
    controller: ($scope, $element) ->
      $scope.selected_categories = {}
      $scope.selected_activities = {}
      $scope.selected_contents = {}
      $scope.selected_time = false
      $scope.filter_query = ''
      $scope.filterItems = filterItems
      return
    link: (scope, element, attr, controller) ->

      setAndApplyFilter = (value, oldvalue, scope) ->
        categories = (k for k,v of scope.selected_categories when v == true)
        activities = (k for k,v of scope.selected_activities when v == true)
        contents = (k for k,v of scope.selected_contents when v == true)
        time = scope.selected_time
        query = scope.filter_query.trim()
        if categories.length isnt 0 or activities.length isnt 0 or contents.length isnt 0 #or time isnt false
          Analytics.trackEvent('sidebar:filterCategories', { categories: categories })
          contributionFilterService.setFilter
            categories: categories
            activities: activities
            contents: contents
        else if time is true
          contributionFilterService.setFilter
            categories: categories
            activities: activities
            contents: contents
            time: time
        else if query isnt ''
          Analytics.trackEvent('sidebar:typeFilter', { query: query })
          contributionFilterService.setFilter
            query: query
        else
          contributionFilterService.resetFilter()

        contributionsToFilter = Contribution.parent_contributions
        if scope.isCurrentContribution
          contributionsToFilter = [Contribution.currentContribution]

        contributionFilterService.applyFilter contributionsToFilter, scope.isCurrentContribution, (filtered_contributions) ->
          Contribution.display_contributions = filtered_contributions
          return

        angular.element('#contributions-scroller').scrollTop(0)

        scope.filterCount = {
          categories: categories.length
          activities: activities.length
          contents: contents.length
          time: (if time is true then 1 else 0)
          query: (if query isnt '' then 1 else 0)
          all: (categories.length + activities.length + contents.length + (if time is true then 1 else 0) + (if query isnt '' then 1 else 0))
        }
        return

      scope.$watchCollection 'selected_categories', setAndApplyFilter
      scope.$watchCollection 'selected_activities', setAndApplyFilter
      scope.$watchCollection 'selected_contents', setAndApplyFilter
      scope.$watchCollection 'selected_time', setAndApplyFilter
      scope.$watch 'filter_query', setAndApplyFilter

      scope.$watch 'filterVisible', (value) ->
        filterElem = angular.element('#filter')
        top = parseInt(filterElem.css('height')) + filterElem.position().top
        angular.element('#contributions-scroller').css('height', "calc(100% - #{top}px)")
        return

      scope.resetAllFilters = ->
        scope.selected_categories = {}
        scope.selected_activities = {}
        scope.selected_contents = {}
        scope.selected_time = false
        scope.filter_query = ''
        return

      scope.track = (action, data) ->
        Analytics.trackEvent(action, data)
        return

      return
]
