angular.module('DialogMapApp').service "descriptionTagHelper", ->
  @featureReferenceTypeIndicatorHtml = (text, icon_type) ->
    "<span contenteditable=\"false\" class=\"userselect_none\"><span contenteditable=\"false\" class=\"userselect_none contribution-icon #{icon_type}\"></span>(#{text})</span>"
  @createTagTitleNode = (contenteditable) ->
    tagTitleNode = document.createElement('span')
    tagTitleNode.className = "tag-title"
    tagTitleNode.setAttribute('contenteditable', (if contenteditable then 'true' else 'false'))
    tagTitleNode
  @createTagTitleNodeForFeatureReference = (reference) ->
    tagTitleNode = @createTagTitleNode(false)
    refNode = document.createElement('span')
    refNode.innerHTML = @featureReferenceTypeIndicatorHtml(reference.referenceTo.properties.title,reference.referenceTo.geometry.type)
    tagTitleNode.appendChild(document.createTextNode("#{reference.title} "))
    tagTitleNode.appendChild(refNode)
    tagTitleNode
  @createTagTitleNodeForUrlReference = (text, url) ->
    tagTitleNode = @createTagTitleNode(false)
    linkNode = document.createElement('a')
    linkNode.href = url
    linkNode.setAttribute('target', '_blank')
    linkNode.appendChild(document.createTextNode("#{text}"))
    tagTitleNode.setAttribute('title', url)
    tagTitleNode.appendChild(linkNode)
    tagTitleNode
  @createReplacementNode = (text, icon_type, box_type, clickDelete, clickExistingUrlReference) ->
    replacementNode = document.createElement('div')
    replacementNode.className = "contribution-description-tag #{box_type}_tag"
    replacementNode.setAttribute('contenteditable', 'false')
    replacementNode.setAttribute('type', box_type)
    replacementNode.setAttribute('type_id',(if box_type is 'url_reference' then 'http%3A%2F%2F' else 'new'))

    iconNode = document.createElement('span')
    iconNode.className = "contribution-icon #{icon_type}"
    iconNode.setAttribute('contenteditable', 'false')

    if typeof text == "string"
      textNode = @createTagTitleNode(clickDelete)
      textNode.appendChild(document.createTextNode(text))
    else
      textNode = text

    if clickExistingUrlReference?
      textNode.addEventListener('click', clickExistingUrlReference)

    if clickDelete?
      closeNode = document.createElement('a')
      closeNode.appendChild(document.createTextNode('×'))
      closeNode.className = 'tag-close'
      closeNode.setAttribute('href','')
      closeNode.setAttribute('contenteditable', 'false')
      closeNode.setAttribute('draggable', 'false')
      closeNode.setAttribute("type_id", (if box_type is 'url_reference' then 'http%3A%2F%2F' else 'new'))
      closeNode.setAttribute('type', box_type)
      closeNode.addEventListener('click', clickDelete)
      closeNode.setAttribute('ng-click', 'clickDelete()')

    replacementNode.appendChild(iconNode)
    replacementNode.appendChild(textNode)
    replacementNode.appendChild(closeNode) if clickDelete?


    replacementNode

  return
