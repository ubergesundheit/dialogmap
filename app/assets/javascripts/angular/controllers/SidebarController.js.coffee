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
      createSearchChoice: (term) ->
        {id: term, text: "Neue Kategorie: #{term}"}
      format: (state) ->
        state.color = stringToColor.hex(state.id) unless state.color?
        "<div class='category-color' style='background-color: #{state.color};'></div>&nbsp;#{state.text}"
      initSelect2: ->
        # fetch categories from server
        compileAndInit = (response) ->
          $scope.selectOpts =
            data: response.data || []
            multiple: false
            createSearchChoice: $scope.createSearchChoice
            formatResult: $scope.format
            formatSelection: $scope.format
            placeholder: 'Kategorie'
          angular.element('input.category_input').attr("ui-select2", "selectOpts")
          $compile(angular.element('input.category_input'))($scope)
          return
        $http.get('/api/contributions/categories').then(compileAndInit, compileAndInit)
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
      angular.element('.category_input').select2('destroy')
      return

    return
]
