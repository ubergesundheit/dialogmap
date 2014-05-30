L.Icon.Default.imagePath = 'assets/'
angular.module "SustainabilityApp", ["leaflet-directive", "rails", "ngTagsInput", "Devise", "ngDialog", "ngContentEditable", "ngSanitize", "ngQueue", "ui.router"]
.config [
  "$stateProvider"
  "$urlRouterProvider"
  ($stateProvider, $urlRouterProvider) ->

    $urlRouterProvider.otherwise("/")
    $stateProvider
      .state 'contributions',
        url: "/"
        templateUrl: "contributions_show.html"

      .state 'contribution',
        url: "/:id"
        templateUrl: "contribution_show.html"
]
