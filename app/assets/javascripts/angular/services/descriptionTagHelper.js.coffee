angular.module('SustainabilityApp').service "descriptionTagHelper", ->
  @featureReferenceTypeIndicatorHtml = (text, icon_type) ->
    "<span contenteditable=\"false\" class=\"userselect_none\"><span contenteditable=\"false\" class=\"userselect_none contribution-icon #{icon_type}\"></span>(#{text})</span>"
  @createTagTitleNodeForFeatureReference = (reference) ->
    tagTitleNode = document.createElement('span')
    tagTitleNode.appendChild(document.createTextNode("#{reference.title} "))
    refNode = document.createElement('span')
    refNode.innerHTML = @featureReferenceTypeIndicatorHtml(reference.referenceTo.properties.title,reference.referenceTo.geometry.type)
    tagTitleNode.appendChild(refNode)
    tagTitleNode.className = "tag-title"
    tagTitleNode.setAttribute('contenteditable', 'false')
    tagTitleNode
  @createReplacementNode = (text, icon_type, box_type, clickDelete) ->
    replacementNode = document.createElement('div')
    replacementNode.className = "contribution-description-tag #{box_type}_tag"
    replacementNode.setAttribute('contenteditable', 'false')
    replacementNode.setAttribute('type', box_type)
    replacementNode.setAttribute('type_id','new')

    iconNode = document.createElement('span')
    iconNode.className = "contribution-icon #{icon_type}"
    iconNode.setAttribute('contenteditable', 'false')

    if typeof text == "string"
      textNode = document.createElement('span')
      textNode.appendChild(document.createTextNode(text))
      textNode.className = "tag-title"
      textNode.setAttribute('contenteditable', (if clickDelete? then 'true' else 'false'))
    else
      textNode = text

    if clickDelete?
      closeNode = document.createElement('a')
      closeNode.appendChild(document.createTextNode('×'))
      closeNode.className = 'tag-close'
      closeNode.setAttribute('href','#')
      closeNode.setAttribute('contenteditable', 'false')
      closeNode.setAttribute('draggable', 'false')
      replacementNode.setAttribute('type', box_type)
      closeNode.setAttribute("type_id", 'new')
      closeNode.setAttribute('type', box_type)
      closeNode.addEventListener('click', clickDelete)
      closeNode.setAttribute('ng-click', 'clickDelete()')

    replacementNode.appendChild(iconNode)
    replacementNode.appendChild(textNode)
    replacementNode.appendChild(closeNode) if clickDelete?

    replacementNode

  return
