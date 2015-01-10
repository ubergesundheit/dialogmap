angular.module("DialogMapApp").directive 'legendMatrix', [
  'filterItems'
  'colorService'
  (filterItems, colorService) ->
    restrict: 'A'
    templateUrl: 'legend_matrix.html'
    controller: ($scope, $element) ->
      detailTexts =
        "Bürger- und Zivilgesellschaft": "Die informellen und formellen Vereinigungen von Bürgerinnen und Bürger (Vereine, Stiftungen, Aktionsbündnisse verschiedenen Akteursgruppen"
        "Bildung und Wissenschaft": "Universität, Hochschulen, Schulen und andere öffentliche Bildungseinrichtungen"
        "Stadt und Politik": "Städtische Ämter und Angestellte der Stadtverwaltung, aber auch die Stadtpolitikdurch die lokalen Parteien"
        "Wirtschaft": "Vereinigungen, die wirtschaftliche Zwecke verfolgen"
        "Informieren": "Informationen und Daten über Initiativen und Projekte"
        "Diskutieren": "Diskussionsveranstaltungen und Austauschmöglichkeiten"
        "Mitmachen": "Projekte und Initiativen, die Möglichkeiten zur aktiven Beteiligung bieten"
        "Vorschlagen": "Ideen und Vorschläge zur Gestaltung Münsters und seiner Viertel"
      angular.extend $scope,
        filterItems: filterItems
        items:[
          { id: 'International', icon: 'embassy', color: '#006BB6'},
          { id: 'Kultur', icon: 'theatre', color: '#231F20'},
          { id: 'Umwelt und Nachhaltigkeit', icon: 'park2', color: '#00884B'},
          { id: 'Sport', icon: 'pitch', color: '#00AEEF'},
          { id: 'Soziales', icon: 'hospital', color: '#7E5038'},
          { id: 'Senioren', icon: 'toilets', color: '#F0543A'},
          { id: 'Kinder und Jugendliche', icon: 'school', color: '#ED028C'}
        ]
        getBackgroundCSS: (icon, color) ->
          "#{colorService.lightenColor(color)}  url(//a.tiles.mapbox.com/v3/marker/pin-m-#{icon}+#{color.slice(1)}.png) no-repeat center 0px"
        setDetails: (cat,act) ->
          $scope.details[0] =
            title: cat
            text: detailTexts[cat.trim()]
          if act?
            $scope.details[1] =
              title: act
              text: detailTexts[act.trim()]
          else
            $scope.details[1] = { title: "", text: ""}
          return
        details: [{ title: "", text: "" }, { title: "", text: ""} ]
      return
]
