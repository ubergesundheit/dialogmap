angular.module('DialogMapApp').service "contributionTransformer", [
  "leafletData"
  "propertiesHelper"
  "descriptionTagHelper"
  "stringToColor"
  (leafletData, propertiesHelper, descriptionTagHelper, stringToColor) ->
    @createContributionForSubmit = (contribution) ->
      leafletData.getMap('map_main').then (map) ->
        features_attributes = []
        descr = contribution.description.replace(new RegExp(String.fromCharCode(160), "g"), " ").replace(/&nbsp;/g, " ")
        descr = descr.replace(/^(<br>)*(<\/br>)*/,"")
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
              # create the properties
              props = propertiesHelper.createProperties(tag_title,geojson.geometry.type, stringToColor.hex(contribution.category.id))
              # append or update the properties
              angular.extend(geojson.properties, props)
              # set the contributionId to undefined
              geojson.properties.contributionId = undefined
              features_attributes.push { geojson: geojson, leaflet_id: id }
              descr = descr.replace(tag.outerHTML, "%[#{id}]%")
            else if type == 'feature_reference'
              # this could be a problem if the user types in a name that contains "<span"
              tag_title = tag_title.slice(0,tag_title.indexOf("<span")-1)

              (fRef.title = tag_title) for fRef in contribution.references when fRef.ref_id is parseInt(id)

              descr = descr.replace(tag.outerHTML, "#[#{id}]#")
            else if type == 'url_reference'
              descr = descr.replace(tag.outerHTML, "&[#{id}|#{encodeURIComponent(tag_title)}]&")
            return

        descr = descr.replace(/^<div class="ng-scope">/, "")
        descr = descr.replace(/<\/div>$/, "")
        descr = descr.replace(/<div class="ng-scope"><\/div>/g,"")

        {
          title: contribution.title
          description: descr.replace(/<br>$/, "")
          features_attributes: features_attributes
          references_attributes: contribution.references
          parent_id: contribution.parent_contribution
          category: contribution.category.id
        }
    @createFancyContributionFromRaw = (contribution) ->
      featureReplacer = (match, offset, string) ->
        id = parseInt(match.split("").slice(2,match.length-2).join(""))
        "<div feature-tag=\"#{id}\" type=\"feature\"></div>"

      featureReferenceReplacer = (match, offset, string) ->
        id = parseInt(match.split("").slice(2,match.length-2).join(""))
        "<div feature-tag=\"#{id}\" type=\"feature_reference\"></div>"

      urlReferenceReplacer = (match, offset, string) ->
        ref = match.split('|')
        title = decodeURIComponent(ref[1].slice(0, ref[1].length-2))
        url = decodeURIComponent(ref[0].slice(2))
        "<div feature-tag=\"true\" type=\"url_reference\" title=\"#{title}\" url=\"#{url}\"></div>"

      contribution.description = contribution.description.replace(/%\[\d+\]%/g, featureReplacer)
      contribution.description = contribution.description.replace(/#\[\d+\]#/g, featureReferenceReplacer)
      contribution.description = contribution.description.replace(/&\[[0-9a-zA-Z-_.!~*'\(\)%]+\|[^\[&]+\]&/g, urlReferenceReplacer)
      contribution.description = "<div>#{contribution.description}</div>"

      contribution
    @createFancyContributionDescription = (description) ->
      @createFancyContributionFromRaw({ description: description}).description

    return
]
