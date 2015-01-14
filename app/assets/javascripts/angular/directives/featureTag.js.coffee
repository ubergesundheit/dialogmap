angular.module("DialogMapApp").directive 'featureTag', [
  "Analytics"
  (Analytics) ->
    templateUrl: (elem,attrs) ->
      switch attrs.type
        when "feature" then "feature_tag_static.html"
        when "feature_reference" then "feature_reference_tag_static.html"
        when "url_reference" then "url_tag_static.html"
    scope: true
    replace: true
    link: (scope, element, attrs) ->
      tagId = parseInt(attrs.featureTag)
      # hackity hack :)
      if !scope.contribution? then scope.contribution = scope.Contribution.currentContribution
      switch attrs.type
        when "feature"
          scope.tag = f for f in scope.contribution.features when f.id is tagId
        when "feature_reference"
          scope.tag = r for r in scope.contribution.references when r.refId is tagId
        when "url_reference"
          scope.tag =
            title: attrs.title
            url: attrs.url
      scope.track = (action, data) ->
        Analytics.trackEvent(action, data)
        return
      return

]
