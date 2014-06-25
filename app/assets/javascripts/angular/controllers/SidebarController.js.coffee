angular.module("DialogMapApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  "$state"
  "$rootScope"
  "$http"
  "stringToColor"
  ($scope, Contribution, User, $compile, $state, $rootScope, $http, stringToColor) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
      createCategorySearchChoice: (term) ->
        {id: term, text: "Neue Kategorie: #{term}"}
      createActivitySearchChoice: (term) ->
        {id: term, text: "Neue Aktivität: #{term}"}
      createContentSearchChoice: (term) ->
        {id: term, text: "Neuer Inhalt: #{term}"}
      formatCategory: (state) ->
        state.color = stringToColor.hex(state.id) unless state.color?
        "<div class='category-color' style='background-color: #{state.color};'></div>&nbsp;#{state.text}"
      formatActivity: (state) ->
        if !state.icon?
          first_char = state.id.charAt(0).toLowerCase()
          state.icon = switch
            when first_char is '0' then 'zero'
            when first_char is '1' then 'one'
            when first_char is '2' then 'two'
            when first_char is '3' then 'three'
            when first_char is '4' then 'four'
            when first_char is '5' then 'five'
            when first_char is '6' then 'six'
            when first_char is '7' then 'seven'
            when first_char is '9' then 'nine'
            else first_char
        "<div class=\"maki-icon #{state.icon}\"></div><span class=\"activity-label\">&nbsp;#{state.text}</span>"
      initSelect2: ->
        compileAndInitCategory = (response) ->
          $scope.categorySelectOpts =
            data: response.data || []
            multiple: false
            createSearchChoice: $scope.createCategorySearchChoice
            formatResult: $scope.formatCategory
            formatSelection: $scope.formatCategory
            placeholder: 'Kategorie'
          angular.element('input#category.category_input').attr("ui-select2", "categorySelectOpts")
          $compile(angular.element('input#category.category_input'))($scope)
          return
        compileAndInitActivity = (response) ->
          $scope.activitySelectOpts =
            data: response.data || []
            multiple: false
            createSearchChoice: $scope.createActivitySearchChoice
            formatResult: $scope.formatActivity
            formatSelection: $scope.formatActivity
            placeholder: 'Aktivität'
          angular.element('input#activity.category_input').attr("ui-select2", "activitySelectOpts")
          $compile(angular.element('input#activity.category_input'))($scope)
          return
        compileAndInitContent = (response) ->
          $scope.contentSelectOpts =
            data: response.data || []
            multiple: false
            createSearchChoice: $scope.createContentSearchChoice
            placeholder: 'Inhalt'
          angular.element('input#content.category_input').attr("ui-select2", "contentSelectOpts")
          $compile(angular.element('input#content.category_input'))($scope)
          return
        # fetch items from server
        $http.get('/api/contributions/categories').then(compileAndInitCategory, compileAndInitCategory)
        $http.get('/api/contributions/activities').then(compileAndInitActivity, compileAndInitActivity)
        $http.get('/api/contributions/contents').then(compileAndInitContent, compileAndInitContent)
        return
      startNewTopic: ->
        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element('#new-topic-container').append(inputAreaHtml)

        $scope.initSelect2()
        Contribution.start()
        return

      # id is the parent_id
      startAnswer: (id) ->
        angular.element('.composing_container').remove()

        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element(".contribution_input_replace[data-id=#{id}]").append inputAreaHtml
        Contribution.start(id)
        return

      startContributionEdit: (id) ->
        Contribution.setContributionForEdit(id)

        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" contribution_input=\"contribution\"></div>")($scope)
        angular.element(".contribution_input_replace[data-id=#{id}][type=edit]").append inputAreaHtml
        # only initialize the category selector if the contribution is a parent
        Contribution.getContribution(id).then (c) ->
          $scope.initSelect2() if !c.parentId?
          return
        Contribution.start(id)
        return

      highlightRelated: (feature_id, $event) ->
        target = angular.element($event.target)
        while target.is('span')
          target = angular.element(target.parent())
        target.addClass('highlight')
        $rootScope.$broadcast('highlightFeature', { feature_id: feature_id } )
        return

      resetHighlight: (feature_id, $event) ->
        target = angular.element($event.target)
        while target.is('span')
          target = angular.element(target.parent())
        target.removeClass('highlight')
        $rootScope.$broadcast('resetHighlight', { feature_id: feature_id })
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

    $scope.$on 'highlightFeature', (event, data) ->
      id = data.feature_id
      angular.element(".contribution-description-tag[feature-tag=#{id}]").addClass('highlight')
      return

    $scope.$on 'resetHighlight', (event, data) ->
      id = data.feature_id
      angular.element(".contribution-description-tag[feature-tag=#{id}]").removeClass('highlight')
      return

    $scope.$on 'Contribution.reset', ->
      angular.element('input#category.category_input').select2('destroy')
      angular.element('input#content.category_input').select2('destroy')
      angular.element('input#activity.category_input').select2('destroy')
      return

    return
]
