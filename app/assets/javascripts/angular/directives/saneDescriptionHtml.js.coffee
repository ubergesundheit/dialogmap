angular.module("DialogMapApp").directive 'saneDescriptionHtml', [
  '$compile'
  '$parse'
  '$rootScope'
  ($compile, $parse, $rootScope) ->
    controller: ($scope, $element) ->
      angular.extend $scope,
        wumbo: ->
          console.log 'wum'
          return
    link: (scope, element, attr) ->
      element.addClass('ng-binding').data('$binding', attr.saneDescriptionHtml)

      parsed = $parse(attr.saneDescriptionHtml);
      getStringValue = ->  (parsed(scope) || '').toString()

      scope.$watch getStringValue, (value) ->
        # element.html($sce.getTrustedHtml(parsed(scope)) || '')
        insane_html = parsed(scope)
        if insane_html?
          insane_html = insane_html.replace(/<script/g, '')
          insane_html = insane_html.replace(/<link/g, '')
          insane_html = insane_html.replace(/<embed/g, '')
          insane_html = insane_html.replace(/<object/g, '')
        sane_html = $compile("<div>#{insane_html}</div>")(scope)
        element.html(sane_html.html() || '')
        return

]
