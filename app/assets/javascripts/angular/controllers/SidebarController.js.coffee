angular.module("SustainabilityApp").controller "SidebarController", [
  "$scope"
  "Contribution"
  ($scope, Contribution) ->
    #ct = new Contribution
    angular.extend $scope,
      start_contribution: ->
        #new Contribution
        #  title: 'wat',
        #  description: 'oida',
        #  features_attributes: [
        #    {geojson:
        #      type: "Feature"
        #      geometry:
        #        type: 'Point',
        #        coordinates: [7,52]
        #      properties:
        #        stroke: 4
        #    }
        #    {geojson:
        #      type: "Feature"
        #      geometry:
        #        type: 'Point',
        #        coordinates: [7,500]
        #      properties:
        #        title: 'wat'
        #    }
        #  ]
        #.create()
        ct = Contribution
        console.log ct
        console.log ct.serialize()
        return
      jottsn: Contribution.features
      #title: Contribution.title

    return
]
