angular.module('DialogMapApp').service "stringToColor", ->
  @hex = (string) ->
    hash = 0
    return hash if !string? or string.length < 4
    i = 0
    l = string.length

    while i < l
      char = string.charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash |= 0 #Convert to 32bit integer
      i++

    hash = Math.abs(hash) % 16777215

    "##{hash.toString(16)}"

  return
