angular.module("DialogMapApp").directive 'droptarget', ->
  restrict: 'AE'
  link: (scope, element, attrs, controller) ->
    element[0].addEventListener(
      "dragover",
      (e) ->
        e.preventDefault()
        e.stopPropagation()
        false
      ,
      false
    )
    element[0].addEventListener(
      "dragleave",
      (e) ->
        e.preventDefault()
        e.stopPropagation()
        false
      ,
      false
    )
    element[0].addEventListener(
      'drop',
      (e)->
        # console.log e
        #
        # range=document.createRange()
        # range.setStart(e.rangeParent,e.rangeOffset)
        # console.log range
        # #e.preventDefault()
        # if e.stopPropagation
        #   e.stopPropagation();
        # e.dataTransfer.effectAllowed = 'move';
        #
        # console.log JSON.parse(e.dataTransfer.getData('reference'))

        return
        # e.dataTransfer.setData('application/json', { bam: "oida" });
        #this.classList.add('drag');
        #return false;
      ,
      false
    )
    return
