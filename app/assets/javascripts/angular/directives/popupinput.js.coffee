angular.module("SustainabilityApp").directive 'popupInput', ->
  restrict: 'AE'
  #require: 'ngModel'
  transclude: true
  templateUrl: 'popupcontent_edit.html'
  #scope: true
  controller: ($scope) ->
    # pre-configure the popup object for polygons and markers
    $scope.popups = { "title": "", "description": "" }
    if $scope.layer_type == "marker"
      $scope.popups["marker-size"] = "medium"
      $scope.popups["marker-symbol"] = "circle-stroked"
      $scope.popups["marker-color"] = "#004e00"
    else if $scope.layer_type == "rectangle" or $scope.layer_type == "polygon"
      $scope.popups["stroke"] = "#629d62"
      $scope.popups["stroke-opacity"] = 1.0
      $scope.popups["stroke-width"] = 1.0
      $scope.popups["fill"] = "#3bc43b"
      $scope.popups["fill-opacity"] = 0.6
    return
  #link: (scope, element, attrs, controller) ->
  #  return

