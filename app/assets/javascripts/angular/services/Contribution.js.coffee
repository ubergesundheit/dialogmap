angular.module('SustainabilityApp').factory 'Contribution', [
  'railsResourceFactory'
  (railsResourceFactory) ->
    ContributionResource = railsResourceFactory
      url: "/api/contributions"
      name: 'contribution'

    class Contribution extends ContributionResource
      @addFeature: (feature) ->
        @features.push { geojson: feature }
      @features: []
]
