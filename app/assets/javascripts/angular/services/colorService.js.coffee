angular.module('DialogMapApp').service "colorService", ->
  @stringToHexColor = (string) ->
    hash = 0
    return hash if !string? or string.length < 4
    i = 0
    l = string.length

    while i < l
      char = string.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash |= 0 #Convert to 32bit integer
      i++

    hash = Math.abs(hash) #% 16777215

    "##{hash.toString(16).slice(0,6)}"

  @lightenColor = (input) ->
    if input?
      Spectra(input).desaturate(10).lighten(35).rgbaString()

  @highlightColor = (input) ->
    if input?
      Spectra(input).lighten(30).rgbaString()

  @complementColor = (input) ->
    if input?
      Spectra(input).complement().rgbaString()

  return
