###*
Analytics tracking

@author Maikel Daloo
@date 22th March 2013
@link https://gist.github.com/maikeldaloo/5218712

###
angular.module('DialogMapApp').factory "Analytics", [
  "$window"
  "leafletData"
  "$rootScope"
  "$http"
  "User"
  ($window, leafletData, $rootScope, $http, User) ->
    PROJECT_ID = '54b6884e96773d36ffcb1d4a'
    EVENT_COLLECTION = 'tracking'
    WRITE_KEY = '31adb1ece004f241d3420bf26ae3e344f9813ade5f4544035a6eed1689bb72a67ae75ba01ebe4c6b044cb0f69c60f8731a3c7f575a1c742cb9baae9f77cee1b171bd8fe938496906f99de0faa3e2dd452631e6632d36943882f347027cc460789a206fba330294a9b91db7ebc4798621'
    url = "https://api.keen.io/3.0/projects/#{PROJECT_ID}/events/#{EVENT_COLLECTION}?api_key=#{WRITE_KEY}"
    return (

      ###*
      Tracks a custom event.
      This is useful for tracking specific actions, such as how many times
      a video is played.

      @param  {string} category Required category name
      @param  {string} action Required action
      @param  {json} label Optional label

      @return {boolean}
      ###
      trackEvent: (action, data) ->
        if action.length
          return leafletData.getMap('map_main').then (map) ->
            if !data?
              data = {}
            data.map =
              zoom: map.getZoom()
              bounds:
                sw: map.getBounds()._southWest
                ne: map.getBounds()._northEast
            data.fingerprint = $rootScope.browserFingerprintForGa
            if User.user?
              data.user = User.user.id
            data.timestamp = Date.now()
            data.action = action
            $http.post(url, data)
            # $window.ga "send", "event", category, action, JSON.stringify(label), { useBeacon: true }
            true
        false
    )
]