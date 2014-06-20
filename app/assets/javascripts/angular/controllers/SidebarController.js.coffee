angular.module("DialogMapApp")
.filter 'strToHex', [ "stringToColor", (stringToColor)  ->
  (input) ->
    stringToColor.hex(input) || ""
]
.controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  "$state"
  "$rootScope"
  "stringToColor"
  "$http"
  ($scope, Contribution, User, $compile, $state, $rootScope, stringToColor, $http) ->
    angular.extend $scope,
      Contribution: Contribution
      User: User
      createSearchChoice: (term) ->
        {id: term, text: "Neue Kategorie: #{term}"}
      format: (state) ->
        "<div class='category-color' style='background-color: #{stringToColor.hex(state.id)};'></div>&nbsp;#{state.text}"
      initSelect2: ->
        # fetch categories from server
        $http.get('/api/contributions/categories')
          .success (data, status, headers, config) ->
            $scope.selectOpts =
              data: data
              multiple: false
              createSearchChoice: $scope.createSearchChoice
              formatResult: $scope.format
              formatSelection: $scope.format
            angular.element('input.category_input').attr("ui-select2", "selectOpts")
            $compile(angular.element('input.category_input'))($scope)
            return
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

        $scope.initSelect2()
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

    $scope.selectOpts =
      data: []
      multiple: false
      createSearchChoice: $scope.createSearchChoice
      formatResult: $scope.format
      formatSelection: $scope.format

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
