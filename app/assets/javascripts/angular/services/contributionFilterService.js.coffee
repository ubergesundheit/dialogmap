angular.module('DialogMapApp').service "contributionFilterService",[
  '$rootScope'
  ($rootScope) ->
    resetFilter: ->
      @_categories = undefined
      @_activities = undefined
      @_contents = undefined

      return
    # filter_items is an object with the keys
    # categories (array or string)
    # activities (array or string)
    # contents (array or string)
    setFilter: (filter_items) ->
      if filter_items?
        if filter_items.categories?
          @_categories =  if angular.isArray(filter_items.categories) then filter_items.categories else [filter_items.categories]
        if filter_items.activities?
          @_activities =  if angular.isArray(filter_items.activities) then filter_items.activities else [filter_items.activities]
        if filter_items.contents?
          @_contents =  if angular.isArray(filter_items.contents) then filter_items.contents else [filter_items.contents]
      return
    applyFilter: (contributions, includeChildren, callback) ->
      if !callback?
        callback = includeChildren

      augmented_contributions = contributions
      if @_categories? or @_activities? or @_contents?
        augmented_contributions = []
        if @_categories?
          augmented_contributions.push c for c in contributions when c.category.id in @_categories
        if @_activities?
          (augmented_contributions.push c if c not in augmented_contributions) for c in contributions when c.activity.id in @_activities
        if @_contents?
          for c in contributions
            contribution_contents = (ct.id for ct in c.content)
            [@_contents, contribution_contents] = [contribution_contents, @_contents] if @_contents.length > contribution_contents.length
            (augmented_contributions.push c if c not in augmented_contributions) for content in @_contents when content in contribution_contents
        callback(augmented_contributions)
      else
        callback(augmented_contributions)
      $rootScope.$broadcast 'map.updateFeatures',
        contributions: augmented_contributions,
        focusFeatures: true
        includeChildren: (includeChildren if typeof includeChildren is 'boolean')
      return
]
