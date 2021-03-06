L.Icon.Default.imagePath = 'assets'
L.Map = L.Map.extend
  openPopup: (popup) ->
    @_popup = popup
    @addLayer(popup).fire "popupopen",
      popup: @_popup


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
  "perfect_scrollbar"
  "flow"
  "ngCookies"
  "angularSimpleSlider"
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
              $rootScope.$broadcast 'resetHighlight'
              angular.element('#contributions-scroller').scrollTop(0)
              return
            ]

      .state 'contribution',
        url: "/:id"
        templateUrl: "contribution_show.html"
        resolve:
          a: [
            "Contribution"
            "$stateParams"
            "$rootScope"
            (Contribution, $stateParams, $rootScope) ->
              Contribution.fetchAndSetCurrentContribution($stateParams.id)
              $rootScope.$broadcast 'resetHighlight'
              angular.element('#contributions-scroller').scrollTop(0)
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
    amMoment.changeLocale('de')
  ]
