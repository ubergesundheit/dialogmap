angular.module('DialogMapApp').service "contributionTransformer", [
  "leafletData"
  "propertiesHelper"
  "descriptionTagHelper"
  "$rootScope"
  (leafletData, propertiesHelper, descriptionTagHelper, $rootScope) ->
    @validateContribution = (contribution) ->
      # attributes to validate
      # title
      # description
      # category
      # activity
      # content
      errors = []

      # if the contribution is an answer, title is not needed
      # isAnswer is true, so we can set the validation to it
      if contribution.isAnswer is true
        title_valid = true
      else
        title_valid = (contribution.title? and contribution.title.trim() isnt '')
      description_valid = (contribution.description? and contribution.description.trim() isnt '')
      category_valid = (contribution.category? and contribution.category.id? and contribution.category.id.trim() isnt '')
      activity_valid = (contribution.activity? and contribution.activity.id? and contribution.activity.id.trim() isnt '')
      content_valid = (contribution.content? and contribution.content.length isnt 0)

      errors.push 'Titel' unless title_valid
      errors.push 'Beschreibung' unless description_valid
      errors.push 'Kategorie' unless category_valid
      errors.push 'Aktivität' unless activity_valid
      errors.push 'Inhalte' unless content_valid
      contribution.errors = errors unless errors.length is 0

      title_valid and description_valid and category_valid and activity_valid and content_valid

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
              props = propertiesHelper.createProperties(tag_title,geojson.geometry.type, contribution.category.color, contribution.activity.icon)
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
          category_color: contribution.category.color
          activity: contribution.activity.id
          activity_icon: contribution.activity.icon
          content: (c.id for c in contribution.content)
          start_date: contribution.startDate
          end_date: contribution.endDate
          image: contribution.image
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
