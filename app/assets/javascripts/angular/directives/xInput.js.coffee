angular.module("SustainabilityApp").directive 'refsInput', [ ->
  restrict: 'A',
  require: '?ngModel',
  scope:
    refs: []
    rawContent: '='

]
