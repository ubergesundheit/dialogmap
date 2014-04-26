App.service "Contribution",
  class
    reset: ->
      @title = undefined
      @text = undefined
      @features.features = []
      return
    setTitle: (@title) ->
    setDescription: (@description) ->
    addFeature: (feature) ->
      @features.features.push feature
      return
    features:
      type: "FeatureCollection"
      features: []
