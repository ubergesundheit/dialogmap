angular.module('SustainabilityApp').service "contributionTransformer", [
  "leafletData"
  "propertiesHelper"
  "descriptionTagHelper"
  (leafletData, propertiesHelper, descriptionTagHelper) ->
    @createContributionForSubmit = (contribution) ->
      leafletData.getMap('map_main').then (map) ->
        features_attributes = []
        descr = contribution.description.replace(new RegExp(String.fromCharCode(160), "g"), " ").replace(/&nbsp;/g, " ")
        el = document.createElement('div')
        el.innerHTML = descr
        tags = Array.prototype.slice.call(el.getElementsByClassName('contribution-description-tag'))
        for tag in tags
          do ->
            l_id = tag.getAttribute('leaflet_id')
            tag_title = tag.getElementsByClassName('tag-title')[0].innerHTML
            # create geojson from features and append some properties
            geojson = map.drawControl.options.edit.featureGroup.getLayer(l_id).toGeoJSON()
            geojson.properties = propertiesHelper.createProperties(tag_title,geojson.geometry.type)
            features_attributes.push { geojson: geojson, leaflet_id: l_id }
            descr = descr.replace(tag.outerHTML, "%[#{l_id}]%")

        {
          title: contribution.title
          description: descr.replace(/<br>$/, "")
          features_attributes: features_attributes
          references_attributes: contribution.references.filter (ref) -> !ref.drawnItem?
        }
    @createFancyContributionFromRaw = (contribution) ->
      replacer = (match, offset, string) ->
        id = parseInt(match.split("").slice(2,match.length-2).join(""))
        feature = f for f in contribution.features when f.id is id

        descriptionTagHelper.createReplacementNode(feature.properties.title, feature.geometry.type).outerHTML

      contribution.description = contribution.description.replace(/%\[\d+\]%/g, replacer)
      contribution

    return
]
