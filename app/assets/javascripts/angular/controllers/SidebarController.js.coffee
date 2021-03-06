angular.module("DialogMapApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  "User"
  "$compile"
  "$state"
  "$rootScope"
  "$http"
  "colorService"
  "$timeout"
  ($scope, Contribution, User, $compile, $state, $rootScope, $http, colorService, $timeout) ->
    angular.extend $scope, colorService
    angular.extend $scope,
      Contribution: Contribution
      User: User
      sort: (child) ->
        switch $scope.sortingOrder
          when 'ctNewer'
            return -moment(child.createdAt).format('X')
          when 'ctReplys'
            return if child.childContributions? then -child.childContributions.length else Number.NEGATIVE_INFINITY
          when 'ctFav'
            return if child.favorites? then -child.favorites.length else Number.NEGATIVE_INFINITY
          when 'ctCategory'
            return child.category.id
          when 'ctActivity'
            return child.activity.id
          when 'ctStarting'
            return if child.startDate? and moment(child.startDate).isAfter(moment()) then moment(child.startDate).format('X') - moment().format('X') else Number.POSITIVE_INFINITY
          when 'ctEnding'
            return if child.endDate? and moment(child.startDate).isAfter(moment()) then moment(child.endDate).format('X') - moment().format('X') else Number.POSITIVE_INFINITY
      createCategorySearchChoice: (term) ->
        {id: term, text: "Neuer Akteur: #{term}"}
      createActivitySearchChoice: (term) ->
        {id: term, text: "Neue Funktion: #{term}"}
      createContentSearchChoice: (term) ->
        {id: term, text: "Neuer Inhalt: #{term}"}
      formatCategory: (state) ->
        state.color = $scope.stringToHexColor(state.id) unless state.color?
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
        compileAndInitCategoryActivityContent = (response) ->
          compileAndInitCategory({data: response.data.categories})
          compileAndInitActivity({data: response.data.activities})
          compileAndInitContent({data: response.data.contents})
        compileAndInitCategory = (response) ->
          $scope.categorySelectOpts =
            data: response.data || []
            multiple: false
            createSearchChoice: $scope.createCategorySearchChoice
            formatResult: $scope.formatCategory
            formatSelection: $scope.formatCategory
            placeholder: 'Akteur'
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
            placeholder: 'Funktion'
          angular.element('input#activity.category_input').attr("ui-select2", "activitySelectOpts")
          $compile(angular.element('input#activity.category_input'))($scope)
          return
        compileAndInitContent = (response) ->
          $scope.contentSelectOpts =
            data: response.data || []
            multiple: true
            createSearchChoice: $scope.createContentSearchChoice
            placeholder: 'Inhalte'
          angular.element('div#content.category_input').attr("ui-select2", "contentSelectOpts")
          $compile(angular.element('div#content.category_input'))($scope)
          return
        # fetch items from server
        # TODO use filterItems service. Attach "contribution start event to it to update.."
        $http.get('/api/contributions/filter_items').then(compileAndInitCategoryActivityContent, compileAndInitCategoryActivityContent)
        return
      startNewTopic: ->
        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element('#new-topic-container').append(inputAreaHtml)

        $scope.initSelect2()
        Contribution.start()
        $timeout ->
          angular.element('input.input_title').focus()
          return
        return

      # id is the parent_id
      startAnswer: (id) ->
        $scope.currentlyEditing = 'new'
        angular.element('.composing_container').remove()

        inputAreaHtml = $compile("<div class=\"composing_container\" ng-include=\"'contribution_input.html'\"></div>")($scope)
        angular.element(".contribution_input_replace[data-id=#{id}]").append inputAreaHtml
        Contribution.startAnswer(id)
        $timeout ->
          angular.element('#contributions-scroller').scrollTop(9999)
          return
        return

      startContributionEdit: (id) ->
        $scope.currentlyEditing = id
        Contribution.setContributionForEdit(id)

        angular.element('.composing_container').remove()
        inputAreaHtml = $compile("<div class=\"composing_container\" contribution_input=\"contribution\"></div>")($scope)
        appendElement = angular.element(".contribution_input_replace[data-id=#{id}][type=edit]")
        appendElement.append inputAreaHtml
        # only initialize the category selector if the contribution is a parent
        Contribution.getContribution(id).then (c) ->
          $scope.initSelect2() if !c.parentId?
          return
        Contribution.start(id)
        $timeout ->
          angular.element('#contributions-scroller').scrollTop(appendElement.position().top)
          return
        return

      highlightRelated: (feature_id, $event) ->
        target = angular.element($event.target)
        while target.is('span')
          target = angular.element(target.parent())
        target.addClass('highlight')
        $rootScope.$broadcast('highlightFeature', { feature_id: feature_id } )
        return

      highlightAllRelated: (contribution) ->
        $rootScope.$broadcast('highlightFeature', { feature_id: f.id, contribution_id: contribution.id, dontScroll: true } ) for f in contribution.features
        # $rootScope.$broadcast('highlightFeature', { feature_id: f.refId, contribution_id: contribution.id, dontScroll: true } ) for f in contribution.references
        return

      resetHighlight: ->
        $rootScope.$broadcast 'resetHighlight'
        return

    $scope.$on 'highlightFeature', (event, data) ->
      angular.element(".contribution-description-tag[feature-tag=#{data.feature_id}]").addClass('highlight')
      contribution = angular.element(".contribution[contribution-id=#{data.contribution_id}]")
      contribution.addClass('contribution-hover')
      if !data.dontScroll and contribution? and contribution.position? and contribution.position()?
        angular.element('#contributions-scroller').scrollTop(0)
        angular.element('#contributions-scroller').scrollTop(contribution.position().top)

      return

    $scope.$on 'resetHighlight', (event, data) ->
      angular.element(".contribution-description-tag").removeClass('highlight')
      angular.element(".contribution").removeClass('contribution-hover')
      return

    $scope.$on 'Contribution.abort', ->
      angular.element('input#category.category_input').select2('destroy')
      angular.element('div#content.category_input').select2('destroy')
      angular.element('input#activity.category_input').select2('destroy')
      $scope.currentlyEditing = undefined
      return

    return
]
