angular.module('SustainabilityApp').service "descriptionTagHelper", ->
  @createReplacementNode = (text, type, clickDelete) ->
    replacementNode = document.createElement('div')
    replacementNode.className = 'contribution-description-tag'
    replacementNode.setAttribute('contenteditable', 'false')
    replacementNode.setAttribute('leaflet_id','new')

    iconNode = document.createElement('span')
    iconNode.className = "contribution-icon #{type}"
    iconNode.setAttribute('contenteditable', 'false')

    textNode = document.createElement('span')
    textNode.appendChild(document.createTextNode(text))
    textNode.className = "tag-title"
    textNode.setAttribute('contenteditable', 'true')

    if clickDelete?
      closeNode = document.createElement('a')
      closeNode.appendChild(document.createTextNode('×'))
      closeNode.className = 'tag-close'
      closeNode.setAttribute('href','#')
      closeNode.setAttribute('contenteditable', 'false')
      closeNode.setAttribute('draggable', 'false')
      closeNode.setAttribute('leaflet_id', 'new')
      closeNode.addEventListener('click', clickDelete)
      closeNode.setAttribute('ng-click', 'clickDelete()')

    replacementNode.appendChild(iconNode)
    replacementNode.appendChild(textNode)
    replacementNode.appendChild(closeNode) if clickDelete?

    replacementNode

  return
