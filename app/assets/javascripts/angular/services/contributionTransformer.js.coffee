angular.module('SustainabilityApp').service "contributionTransformer", [
  "leafletData"
  "propertiesHelper"
  "descriptionTagHelper"
  (leafletData, propertiesHelper, descriptionTagHelper) ->
    @createContributionForSubmit = (contribution) ->
      leafletData.getMap('map_main').then (map) ->
        features_attributes = []
        descr = contribution.description.replace(new RegExp(String.fromCharCode(160), "g"), " ").replace(/&nbsp;/g, " ")
        descr = descr.replace(/^(<br>)*(<\/br>)*/,"")
        console.log descr
        el = document.createElement('div')
        el.innerHTML = descr
        tags = Array.prototype.slice.call(el.getElementsByClassName('contribution-description-tag'))
        for tag in tags
          do ->
            type = tag.getAttribute('type')
            id = tag.getAttribute('type_id')
            tag_title = tag.getElementsByClassName('tag-title')[0].innerHTML
            if type == 'feature'
              # create geojson from features and append some properties
              geojson = map.drawControl.options.edit.featureGroup.getLayer(id).toGeoJSON()
              geojson.properties = propertiesHelper.createProperties(tag_title,geojson.geometry.type)
              features_attributes.push { geojson: geojson, feature_id: id }
              descr = descr.replace(tag.outerHTML, "%[#{id}]%")
            else if type == 'feature_reference'
              # this could be a problem if the user types in a name that contains "<span"
              tag_title = tag_title.slice(0,tag_title.indexOf("<span")-1)
              console.log tag_title
              descr = descr.replace(tag.outerHTML, "#[#{id}]#")

        {
          title: contribution.title
          description: descr.replace(/<br>$/, "")
          features_attributes: features_attributes
          references_attributes: contribution.references
        }
    @createFancyContributionFromRaw = (contribution) ->
      featureReplacer = (match, offset, string) ->
        id = parseInt(match.split("").slice(2,match.length-2).join(""))
        feature = f for f in contribution.features when f.id is id
        descriptionTagHelper
          .createReplacementNode(feature.properties.title, feature.geometry.type, 'feature')
          .outerHTML

      featureReferenceReplacer = (match, offset, string) ->
        id = parseInt(match.split("").slice(2,match.length-2).join(""))
        reference = r for r in contribution.references when r.refId is id
        descriptionTagHelper
          .createReplacementNode(descriptionTagHelper.createTagTitleNodeForFeatureReference(reference), 'reference', 'feature_reference')
          .outerHTML

      contribution.description = contribution.description.replace(/%\[\d+\]%/g, featureReplacer)
      contribution.description = contribution.description.replace(/#\[\d+\]#/g, featureReferenceReplacer)
      contribution

    return
]
