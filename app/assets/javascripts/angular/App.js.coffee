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
            "Analytics"
            (Contribution, leafletData, $rootScope, Analytics) ->
              Contribution.abort()
              Contribution.currentContribution = undefined
              Contribution.getContribution()
              $rootScope.$broadcast 'resetHighlight'
              angular.element('#contributions-scroller').scrollTop(0)
              Analytics.trackPageView('/map')
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
            "Analytics"
            (Contribution, $stateParams, $rootScope, Analytics) ->
              Contribution.fetchAndSetCurrentContribution($stateParams.id)
              $rootScope.$broadcast 'resetHighlight'
              angular.element('#contributions-scroller').scrollTop(0)
              Analytics.trackPageView("/map/#{$stateParams.id}")
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

    $rootScope.browserFingerprintForGa = new Fingerprint({screen_resolution: true, canvas: true}).get()
    ((i, s, o, g, r, a, m) ->
      i["GoogleAnalyticsObject"] = r
      i[r] = i[r] or ->
        (i[r].q = i[r].q or []).push arguments
        return

      i[r].l = 1 * new Date()

      a = s.createElement(o)
      m = s.getElementsByTagName(o)[0]

      a.async = 1
      a.src = g
      m.parentNode.insertBefore a, m
      return
    ) window, document, "script", "//www.google-analytics.com/analytics.js", "ga"
    ga "create", "UA-49033468-5",
      cookieDomain: "none"

    ga "require", "linkid", "linkid.js"
    ga "require", "displayfeatures"
    ga "set", "&uid", $rootScope.browserFingerprintForGa

    return
  ]
