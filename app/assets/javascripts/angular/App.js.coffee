L.Icon.Default.imagePath = 'assets'
angular.module "DialogMapApp", [
  "leaflet-directive"
  "rails"
  "Devise"
  "ngDialog"
  "ngSanitize"
  "ui.router"
  "ui.keypress"
  "angularMoment"
  "ui.select2"
  "ngQuickDate"
]
.config [
  "$stateProvider"
  "$urlRouterProvider"
  "ngQuickDateDefaultsProvider"
  ($stateProvider, $urlRouterProvider, ngQuickDateDefaultsProvider) ->
    ngQuickDateDefaultsProvider.set
      placeholder: "Datum/Uhrzeit"
      dateFormat: "dd.MM.yyyy"
      timeFormat: "hh:mm"
      defaultTime: "12:00"
      closeButtonHtml: "<i class='fa fa-times'></i>"
      buttonIconHtml: "<i class='fa fa-calendar'></i>"
      nextLinkHtml: "<i class='fa fa-chevron-right'></i>"
      prevLinkHtml: "<i class='fa fa-chevron-left'></i>"

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
              return
            ]

      .state 'contribution',
        url: "/:id"
        templateUrl: "contribution_show.html"
        resolve:
          a: [
            "Contribution"
            "$stateParams"
            (Contribution, $stateParams) ->
              Contribution.fetchAndSetCurrentContribution($stateParams.id)
              return
            ]
] #<leaflet center='muenster' controls='controls' event-broadcast='events' geojson='geojson' id='map_main' tiles='tiles'></leaflet>
.run [
  '$rootScope'
  '$state'
  '$stateParams'
  'amMoment'
  ($rootScope, $state, $stateParams, amMoment) ->
    # It's very handy to add references to $state and $stateParams to the $rootScope
    # so that you can access them from any scope within your applications
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
    amMoment.changeLanguage('de')
  ]
