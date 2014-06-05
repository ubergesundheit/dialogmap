L.Icon.Default.imagePath = 'assets/'
angular.module "DialogMapApp", ["leaflet-directive", "rails", "Devise", "ngDialog", "ngSanitize", "ui.router"]
.config [
  "$stateProvider"
  "$urlRouterProvider"
  ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise("/")
    $stateProvider
      .state 'contributions',
        url: "/"
        templateUrl: "contributions_show.html"
        resolve:
          a: [
            "Contribution"
            "leafletData"
            "$rootScope"
            (Contribution, leafletData, $rootScope) ->
              Contribution.abort()
              Contribution.currentContribution = undefined
              Contribution.getContribution()
            ]

      .state 'contribution',
        url: "/:id"
        templateUrl: "contribution_show.html"
        resolve:
          a: [
            "Contribution"
            "$stateParams"
            (Contribution, $stateParams) ->
              Contribution.setCurrentContribution($stateParams.id)
            ]
] #<leaflet center='muenster' controls='controls' event-broadcast='events' geojson='geojson' id='map_main' tiles='tiles'></leaflet>
.run [
  '$rootScope'
  '$state'
  '$stateParams'
  ($rootScope, $state, $stateParams) ->
    # It's very handy to add references to $state and $stateParams to the $rootScope
    # so that you can access them from any scope within your applications
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
  ]
