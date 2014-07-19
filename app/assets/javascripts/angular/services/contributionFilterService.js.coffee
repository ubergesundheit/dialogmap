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
            contribution_summary = ''
            traversePathAndAppend = (target, path, key) ->
              for section in path
                if angular.isArray(target)
                  path.shift()
                  traversePathAndAppend(t, path, key) for t in target
                  return
                else
                  target = target[section]

              if angular.isArray(target)
                contribution_summary += str[key] for str in target
              else
                contribution_summary += target[key]
              return
            appendProperty = (targetObj, obj, path) ->
              for key of obj
                if obj.hasOwnProperty key
                  if obj[key] is true
                    traversePathAndAppend(targetObj, path, key)
                  else if angular.isArray obj[key]
                    newPath = path
                    newPath.push key
                    appendProperty targetObj, item, newPath for item in obj[key]
                  else
                    newPath = path
                    newPath.push key
                    appendProperty targetObj, obj[key], newPath
                  path = []
              return
            # summarize parent
            appendProperty c, @_queryableProperties, []
            # summarize children
            appendProperty child, @_queryableProperties, [] for child in c.childContributions
            # console.log contribution_summary

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
