###*
Analytics tracking

@author Maikel Daloo
@date 22th March 2013
@link https://gist.github.com/maikeldaloo/5218712

Currently set up to use Google Analytics.
If you wish to use another tracking service, update the track methods.
###
angular.module('DialogMapApp').factory "Analytics", [
  "$window"
  ($window) ->
    return (

      ###*
      Tracks a custom event.
      This is useful for tracking specific actions, such as how many times
      a video is played.

      @param  {string} category Required category name
      @param  {string} action Required action
      @param  {string} label Optional label

      @return {boolean}
      ###
      trackEvent: (category, action, label) ->
        if $window.ga and category.length and action.length
          $window.ga "send", "event", category, action, label, { useBeacon: true }
          return true
        false


      ###*
      Tracks a page.
      This is useful for AJAX apps where the page changes without reloading.

      @param  {string} url Required url to track

      @return {boolean}
      ###
      trackPageView: (url) ->
        if $window.ga and url.length
          $window.ga('send', 'pageview', {'page': url})
          return true
        false
    )
]