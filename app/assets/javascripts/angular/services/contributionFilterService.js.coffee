angular.module('DialogMapApp').service "contributionFilterService",[
  '$rootScope'
  ($rootScope) ->
    _queryableProperties:
      title: true
      description: true
      category: { id: true }
      activity: { id: true }
      content: [ { id: true } ]
      user: { email: true }
      features: [ { properties: { title: true } } ]
      references: [ { title: true } ]

    stripContribution: (contribution, props) ->
      # prepare a reduced contribution with only the searchable properties
      wanted_keys = Object.keys(props)
      stripped = []
      for prop of contribution
        if contribution.hasOwnProperty(prop) and prop in wanted_keys
          if angular.isString(contribution[prop])
            stripped.push contribution[prop]
          else
            stripped.push @stripContribution(contribution[prop], props[prop])
      stripped
    concatenateProperties: (contribution) ->
      getPropertyValue = (previousValue, currentValue, index, array) ->
        propertyValue = ""
        if angular.isString(currentValue) is true
          propertyValue = currentValue.trim()
        else if angular.isArray currentValue
          propertyValue = currentValue.reduce getPropertyValue, ""

        previousValue + propertyValue

      # prepare a reduced contribution with only the searchable properties
      c = @stripContribution(contribution, @_queryableProperties)

      c.reduce getPropertyValue, ""
    resetFilter: ->
      @_categories = undefined
      @_activities = undefined
      @_contents = undefined
      @_query = undefined
      @_time = false

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
        if filter_items.time?
          @_time = filter_items.time
        if filter_items.query?
          @_query = filter_items.query
      return
    applyFilter: (contributions, includeChildren, callback) ->
      if !callback?
        callback = includeChildren

      augmented_contributions = []
      if @_categories? or @_activities? or @_contents? or @_query? or @_time is true
        if @_categories?
          augmented_contributions.push c for c in contributions when c.category.id in @_categories
        if @_activities?
          (augmented_contributions.push c if c not in augmented_contributions) for c in contributions when c.activity.id in @_activities
        if @_contents?
          for c in contributions
            contribution_contents = (ct.id for ct in c.content)
            [@_contents, contribution_contents] = [contribution_contents, @_contents] if @_contents.length > contribution_contents.length
            (augmented_contributions.push c if c not in augmented_contributions) for content in @_contents when content in contribution_contents
        if @_time is true
          (augmented_contributions.push c if c not in augmented_contributions) for c in contributions
        if @_query?
          regex = RegExp(@_query.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"), 'i')
          for c in contributions
            contribution_summary = @concatenateProperties c
            for child in c.childContributions
              contribution_summary += @concatenateProperties child

            if c not in augmented_contributions and regex.test(contribution_summary)
              augmented_contributions.push c

        callback(augmented_contributions)
      else
        now = moment()
        augmented_contributions.push c for c in contributions when !(c.startDate? and c.endDate?) or moment(c.endDate).isAfter(now)
        callback(augmented_contributions)
      $rootScope.$broadcast 'map.updateFeatures',
        contributions: augmented_contributions,
        focusFeatures: true
        includeChildren: (includeChildren if typeof includeChildren is 'boolean')
      return
]
