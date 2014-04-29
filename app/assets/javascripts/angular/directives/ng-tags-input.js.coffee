#!
# * ngTagsInput v2.0.1
# * http://mbenford.github.io/ngTagsInput
# *
# * Copyright (c) 2013-2014 Michael Benford
# * License: MIT
# *
#
(->
  SimplePubSub = ->
    events = {}
    on: (names, handler) ->
      names.split(" ").forEach (name) ->
        events[name] = []  unless events[name]
        events[name].push handler
        return

      this

    trigger: (name, args) ->
      angular.forEach events[name], (handler) ->
        handler.call null, args
        return

      this
  makeObjectArray = (array, key) ->
    array = array or []
    if array.length > 0 and not angular.isObject(array[0])
      array.forEach (item, index) ->
        array[index] = {}
        array[index][key] = item
        return

    array
  findInObjectArray = (array, obj, key) ->
    item = null
    i = 0

    while i < array.length

      # I'm aware of the internationalization issues regarding toLowerCase()
      # but I couldn't come up with a better solution right now
      if array[i][key].toLowerCase() is obj[key].toLowerCase()
        item = array[i]
        break
      i++
    item
  replaceAll = (str, substr, newSubstr) ->
    expression = substr.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")
    str.replace new RegExp(expression, "gi"), newSubstr
  "use strict"
  KEYS =
    backspace: 8
    tab: 9
    enter: 13
    escape: 27
    space: 32
    up: 38
    down: 40
    comma: 188

  tagsInput = angular.module("ngTagsInput", [])

  ###
  @ngdoc directive
  @name tagsInput
  @module ngTagsInput

  @description
  Renders an input box with tag editing support.

  @param {string} ngModel Assignable angular expression to data-bind to.
  @param {string=} [displayProperty=text] Property to be rendered as the tag label.
  @param {number=} tabindex Tab order of the control.
  @param {string=} [placeholder=Add a tag] Placeholder text for the control.
  @param {number=} [minLength=3] Minimum length for a new tag.
  @param {number=} maxLength Maximum length allowed for a new tag.
  @param {number=} minTags Sets minTags validation error key if the number of tags added is less than minTags.
  @param {number=} maxTags Sets maxTags validation error key if the number of tags added is greater than maxTags.
  @param {boolean=} [allowLeftoverText=false] Sets leftoverText validation error key if there is any leftover text in
  the input element when the directive loses focus.
  @param {string=} [removeTagSymbol=×] Symbol character for the remove tag button.
  @param {boolean=} [addOnEnter=true] Flag indicating that a new tag will be added on pressing the ENTER key.
  @param {boolean=} [addOnSpace=false] Flag indicating that a new tag will be added on pressing the SPACE key.
  @param {boolean=} [addOnComma=true] Flag indicating that a new tag will be added on pressing the COMMA key.
  @param {boolean=} [addOnBlur=true] Flag indicating that a new tag will be added when the input field loses focus.
  @param {boolean=} [replaceSpacesWithDashes=true] Flag indicating that spaces will be replaced with dashes.
  @param {string=} [allowedTagsPattern=.+] Regular expression that determines whether a new tag is valid.
  @param {boolean=} [enableEditingLastTag=false] Flag indicating that the last tag will be moved back into
  the new tag input box instead of being removed when the backspace key
  is pressed and the input box is empty.
  @param {boolean=} [addFromAutocompleteOnly=false] Flag indicating that only tags coming from the autocomplete list will be allowed.
  When this flag is true, addOnEnter, addOnComma, addOnSpace, addOnBlur and
  allowLeftoverText values are ignored.
  @param {expression} onTagAdded Expression to evaluate upon adding a new tag. The new tag is available as $tag.
  @param {expression} onTagRemoved Expression to evaluate upon removing an existing tag. The removed tag is available as $tag.
  ###
  tagsInput.directive "tagsInput", [
    "$timeout"
    "$document"
    "tagsInputConfig"
    ($timeout, $document, tagsInputConfig) ->
      TagList = (options, events) ->
        self = {}
        getTagText = undefined
        setTagText = undefined
        tagIsValid = undefined
        getTagText = (tag) ->
          tag[options.displayProperty]

        setTagText = (tag, text) ->
          tag[options.displayProperty] = text
          return

        tagIsValid = (tag) ->
          tagText = getTagText(tag)
          tagText.length >= options.minLength and tagText.length <= (options.maxLength or tagText.length) and options.allowedTagsPattern.test(tagText) and not findInObjectArray(self.items, tag, options.displayProperty)

        self.items = []
        self.addText = (text) ->
          tag = {}
          setTagText tag, text
          self.add tag

        self.add = (tag) ->
          tagText = getTagText(tag).trim()
          tagText = tagText.replace(/\s/g, "-")  if options.replaceSpacesWithDashes
          setTagText tag, tagText
          if tagIsValid(tag)
            self.items.push tag
            events.trigger "tag-added",
              $tag: tag

          else
            events.trigger "invalid-tag",
              $tag: tag

          tag

        self.remove = (index) ->
          tag = self.items.splice(index, 1)[0]
          events.trigger "tag-removed",
            $tag: tag

          tag

        self.removeLast = ->
          tag = undefined
          lastTagIndex = self.items.length - 1
          if options.enableEditingLastTag or self.selected
            self.selected = null
            tag = self.remove(lastTagIndex)
          else self.selected = self.items[lastTagIndex]  unless self.selected
          tag

        self
      return (
        restrict: "E"
        require: "ngModel"
        scope:
          tags: "=ngModel"
          onTagAdded: "&"
          onTagRemoved: "&"

        replace: false
        transclude: true
        templateUrl: "ngTagsInput/tags-input.html"
        controller: [
          "$scope"
          "$attrs"
          "$element"
          ($scope, $attrs, $element) ->
            tagsInputConfig.load "tagsInput", $scope, $attrs,
              placeholder: [
                String
                ""
              ]
              tabindex: [Number]
              removeTagSymbol: [
                String
                String.fromCharCode(215)
              ]
              replaceSpacesWithDashes: [
                Boolean
                true
              ]
              minLength: [
                Number
                3
              ]
              maxLength: [Number]
              addOnEnter: [
                Boolean
                true
              ]
              addOnSpace: [
                Boolean
                false
              ]
              addOnComma: [
                Boolean
                true
              ]
              addOnBlur: [
                Boolean
                true
              ]
              allowedTagsPattern: [
                RegExp
                /.+/
              ]
              enableEditingLastTag: [
                Boolean
                false
              ]
              minTags: [Number]
              maxTags: [Number]
              displayProperty: [
                String
                "text"
              ]
              allowLeftoverText: [
                Boolean
                false
              ]
              addFromAutocompleteOnly: [
                Boolean
                false
              ]

            $scope.events = new SimplePubSub()
            $scope.tagList = new TagList($scope.options, $scope.events)
            @registerAutocomplete = ->
              input = $element.find("input")
              input.on "keydown", (e) ->
                $scope.events.trigger "input-keydown", e
                return

              addTag: (tag) ->
                $scope.tagList.add tag

              focusInput: ->
                input[0].focus()
                return

              getTags: ->
                $scope.tags

              getOptions: ->
                $scope.options

              on: (name, handler) ->
                $scope.events.on name, handler
                this
        ]
        link: (scope, element, attrs, ngModelCtrl) ->
          hotkeys = [
            KEYS.enter
            KEYS.comma
            KEYS.space
            KEYS.backspace
          ]
          tagList = scope.tagList
          events = scope.events
          options = scope.options
          input = element.find("input")
          events.on("tag-added", scope.onTagAdded).on("tag-removed", scope.onTagRemoved).on("tag-added", ->
            scope.newTag.text = ""
            console.log scope.tagList
            return
          ).on("tag-added tag-removed", ->
            ngModelCtrl.$setViewValue scope.tags
            return
          ).on("invalid-tag", ->
            scope.newTag.invalid = true
            return
          ).on("input-change", ->
            tagList.selected = null
            scope.newTag.invalid = null
            return
          ).on("input-focus", ->
            ngModelCtrl.$setValidity "leftoverText", true
            return
          ).on "input-blur", ->
            unless options.addFromAutocompleteOnly
              tagList.addText scope.newTag.text  if options.addOnBlur
              ngModelCtrl.$setValidity "leftoverText", (if options.allowLeftoverText then true else not scope.newTag.text)
            return

          scope.newTag =
            text: ""
            invalid: null

          scope.getDisplayText = (tag) ->
            tag[options.displayProperty].trim()

          scope.track = (tag) ->
            tag[options.displayProperty]

          scope.newTagChange = ->
            events.trigger "input-change", scope.newTag.text
            return

          scope.$watch "tags", (value) ->
            scope.tags = makeObjectArray(value, options.displayProperty)
            tagList.items = scope.tags
            return

          scope.$watch "tags.length", (value) ->
            ngModelCtrl.$setValidity "maxTags", angular.isUndefined(options.maxTags) or value <= options.maxTags
            ngModelCtrl.$setValidity "minTags", angular.isUndefined(options.minTags) or value >= options.minTags
            return


          # This hack is needed because jqLite doesn't implement stopImmediatePropagation properly.
          # I've sent a PR to Angular addressing this issue and hopefully it'll be fixed soon.
          # https://github.com/angular/angular.js/pull/4833
          input.on("keydown", (e) ->
            return  if e.isImmediatePropagationStopped and e.isImmediatePropagationStopped()
            key = e.keyCode
            isModifier = e.shiftKey or e.altKey or e.ctrlKey or e.metaKey
            addKeys = {}
            shouldAdd = undefined
            shouldRemove = undefined
            return  if isModifier or hotkeys.indexOf(key) is -1
            addKeys[KEYS.enter] = options.addOnEnter
            addKeys[KEYS.comma] = options.addOnComma
            addKeys[KEYS.space] = options.addOnSpace
            shouldAdd = not options.addFromAutocompleteOnly and addKeys[key]
            shouldRemove = not shouldAdd and key is KEYS.backspace and scope.newTag.text.length is 0
            if shouldAdd
              tagList.addText scope.newTag.text
              scope.$apply()
              e.preventDefault()
            else if shouldRemove
              tag = tagList.removeLast()
              scope.newTag.text = tag[options.displayProperty]  if tag and options.enableEditingLastTag
              scope.$apply()
              e.preventDefault()
            return
          ).on("focus", ->
            return  if scope.hasFocus
            scope.hasFocus = true
            events.trigger "input-focus"
            scope.$apply()
            return
          ).on "blur", ->
            $timeout ->
              activeElement = $document.prop("activeElement")
              lostFocusToBrowserWindow = activeElement is input[0]
              lostFocusToChildElement = element[0].contains(activeElement)
              if lostFocusToBrowserWindow or not lostFocusToChildElement
                scope.hasFocus = false
                events.trigger "input-blur"
              return

            return

          element.find("div").on "click", ->
            input[0].focus()
            return

          return
      )
  ]

  ###
  @ngdoc directive
  @name autoComplete
  @module ngTagsInput

  @description
  Provides autocomplete support for the tagsInput directive.

  @param {expression} source Expression to evaluate upon changing the input content. The input value is available as
  $query. The result of the expression must be a promise that eventually resolves to an
  array of strings.
  @param {number=} [debounceDelay=100] Amount of time, in milliseconds, to wait before evaluating the expression in
  the source option after the last keystroke.
  @param {number=} [minLength=3] Minimum number of characters that must be entered before evaluating the expression
  in the source option.
  @param {boolean=} [highlightMatchedText=true] Flag indicating that the matched text will be highlighted in the
  suggestions list.
  @param {number=} [maxResultsToShow=10] Maximum number of results to be displayed at a time.
  ###
  tagsInput.directive "autoComplete", [
    "$document"
    "$timeout"
    "$sce"
    "tagsInputConfig"
    ($document, $timeout, $sce, tagsInputConfig) ->
      SuggestionList = (loadFn, options) ->
        self = {}
        debouncedLoadId = undefined
        getDifference = undefined
        lastPromise = undefined
        getDifference = (array1, array2) ->
          array1.filter (item) ->
            not findInObjectArray(array2, item, options.tagsInput.displayProperty)


        self.reset = ->
          lastPromise = null
          self.items = []
          self.visible = false
          self.index = -1
          self.selected = null
          self.query = null
          $timeout.cancel debouncedLoadId
          return

        self.show = ->
          self.selected = null
          self.visible = true
          return

        self.load = (query, tags) ->
          if query.length < options.minLength
            self.reset()
            return
          $timeout.cancel debouncedLoadId
          debouncedLoadId = $timeout(->
            self.query = query
            promise = loadFn($query: query)
            lastPromise = promise
            promise.then (items) ->
              return  if promise isnt lastPromise
              items = makeObjectArray(items.data or items, options.tagsInput.displayProperty)
              items = getDifference(items, tags)
              self.items = items.slice(0, options.maxResultsToShow)
              if self.items.length > 0
                self.show()
              else
                self.reset()
              return

            return
          , options.debounceDelay, false)
          return

        self.selectNext = ->
          self.select ++self.index
          return

        self.selectPrior = ->
          self.select --self.index
          return

        self.select = (index) ->
          if index < 0
            index = self.items.length - 1
          else index = 0  if index >= self.items.length
          self.index = index
          self.selected = self.items[index]
          return

        self.reset()
        self
      encodeHTML = (value) ->
        value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace />/g, "&gt;"
      return (
        restrict: "E"
        require: "^tagsInput"
        scope:
          source: "&"

        templateUrl: "ngTagsInput/auto-complete.html"
        link: (scope, element, attrs, tagsInputCtrl) ->
          hotkeys = [
            KEYS.enter
            KEYS.tab
            KEYS.escape
            KEYS.up
            KEYS.down
          ]
          suggestionList = undefined
          tagsInput = undefined
          options = undefined
          getItemText = undefined
          documentClick = undefined
          tagsInputConfig.load "autoComplete", scope, attrs,
            debounceDelay: [
              Number
              100
            ]
            minLength: [
              Number
              3
            ]
            highlightMatchedText: [
              Boolean
              true
            ]
            maxResultsToShow: [
              Number
              10
            ]

          options = scope.options
          tagsInput = tagsInputCtrl.registerAutocomplete()
          options.tagsInput = tagsInput.getOptions()
          suggestionList = new SuggestionList(scope.source, options)
          getItemText = (item) ->
            item[options.tagsInput.displayProperty]

          scope.suggestionList = suggestionList
          scope.addSuggestion = ->
            added = false
            if suggestionList.selected
              tagsInput.addTag suggestionList.selected
              suggestionList.reset()
              tagsInput.focusInput()
              added = true
            added

          scope.highlight = (item) ->
            text = getItemText(item)
            text = encodeHTML(text)
            text = replaceAll(text, encodeHTML(suggestionList.query), "<em>$&</em>")  if options.highlightMatchedText
            $sce.trustAsHtml text

          scope.track = (item) ->
            getItemText item


          # This hack is needed because jqLite doesn't implement stopImmediatePropagation properly.
          # I've sent a PR to Angular addressing this issue and hopefully it'll be fixed soon.
          # https://github.com/angular/angular.js/pull/4833
          tagsInput.on("tag-added invalid-tag", ->
            suggestionList.reset()
            return
          ).on("input-change", (value) ->
            if value
              suggestionList.load value, tagsInput.getTags()
            else
              suggestionList.reset()
            return
          ).on("input-keydown", (e) ->
            key = undefined
            handled = undefined
            return  if hotkeys.indexOf(e.keyCode) is -1
            immediatePropagationStopped = false
            e.stopImmediatePropagation = ->
              immediatePropagationStopped = true
              e.stopPropagation()
              return

            e.isImmediatePropagationStopped = ->
              immediatePropagationStopped

            if suggestionList.visible
              key = e.keyCode
              handled = false
              if key is KEYS.down
                suggestionList.selectNext()
                handled = true
              else if key is KEYS.up
                suggestionList.selectPrior()
                handled = true
              else if key is KEYS.escape
                suggestionList.reset()
                handled = true
              else handled = scope.addSuggestion()  if key is KEYS.enter or key is KEYS.tab
              if handled
                e.preventDefault()
                e.stopImmediatePropagation()
                scope.$apply()
            return
          ).on "input-blur", ->
            suggestionList.reset()
            return

          documentClick = ->
            if suggestionList.visible
              suggestionList.reset()
              scope.$apply()
            return

          $document.on "click", documentClick
          scope.$on "$destroy", ->
            $document.off "click", documentClick
            return

          return
      )
  ]

  ###
  @ngdoc directive
  @name tiTranscludeAppend
  @module ngTagsInput

  @description
  Re-creates the old behavior of ng-transclude. Used internally by tagsInput directive.
  ###
  tagsInput.directive "tiTranscludeAppend", ->
    (scope, element, attrs, ctrl, transcludeFn) ->
      transcludeFn (clone) ->
        element.append clone
        return

      return


  ###
  @ngdoc directive
  @name tiAutosize
  @module ngTagsInput

  @description
  Automatically sets the input's width so its content is always visible. Used internally by tagsInput directive.
  ###
  tagsInput.directive "tiAutosize", ->
    restrict: "A"
    require: "ngModel"
    link: (scope, element, attrs, ctrl) ->
      THRESHOLD = 3
      span = undefined
      resize = undefined
      span = angular.element("<span class=\"input\"></span>")
      span.css("display", "none").css("visibility", "hidden").css("width", "auto").css "white-space", "pre"
      element.parent().append span
      resize = (originalValue) ->
        value = originalValue
        width = undefined
        value = attrs.placeholder  if angular.isString(value) and value.length is 0
        if value
          span.text value
          span.css "display", ""
          width = span.prop("offsetWidth")
          span.css "display", "none"
        element.css "width", (if width then width + THRESHOLD + "px" else "")
        originalValue

      ctrl.$parsers.unshift resize
      ctrl.$formatters.unshift resize
      attrs.$observe "placeholder", (value) ->
        resize value  unless ctrl.$modelValue
        return

      return


  ###
  @ngdoc service
  @name tagsInputConfig
  @module ngTagsInput

  @description
  Sets global configuration settings for both tagsInput and autoComplete directives. It's also used internally to parse and
  initialize options from HTML attributes.
  ###
  tagsInput.provider "tagsInputConfig", ->
    globalDefaults = {}
    interpolationStatus = {}

    ###
    @ngdoc method
    @name setDefaults
    @description Sets the default configuration option for a directive.
    @methodOf tagsInputConfig

    @param {string} directive Name of the directive to be configured. Must be either 'tagsInput' or 'autoComplete'.
    @param {object} defaults Object containing options and their values.

    @returns {object} The service itself for chaining purposes.
    ###
    @setDefaults = (directive, defaults) ->
      globalDefaults[directive] = defaults
      this


    ###
    @ngdoc method
    @name setActiveInterpolation
    @description Sets active interpolation for a set of options.
    @methodOf tagsInputConfig

    @param {string} directive Name of the directive to be configured. Must be either 'tagsInput' or 'autoComplete'.
    @param {object} options Object containing which options should have interpolation turned on at all times.

    @returns {object} The service itself for chaining purposes.
    ###
    @setActiveInterpolation = (directive, options) ->
      interpolationStatus[directive] = options
      this

    @$get = [
      "$interpolate"
      ($interpolate) ->
        converters = {}
        converters[String] = (value) ->
          value

        converters[Number] = (value) ->
          parseInt value, 10

        converters[Boolean] = (value) ->
          value.toLowerCase() is "true"

        converters[RegExp] = (value) ->
          new RegExp(value)

        return load: (directive, scope, attrs, options) ->
          scope.options = {}
          angular.forEach options, (value, key) ->
            type = undefined
            localDefault = undefined
            converter = undefined
            getDefault = undefined
            updateValue = undefined
            type = value[0]
            localDefault = value[1]
            converter = converters[type]
            getDefault = ->
              globalValue = globalDefaults[directive] and globalDefaults[directive][key]
              (if angular.isDefined(globalValue) then globalValue else localDefault)

            updateValue = (value) ->
              scope.options[key] = (if value then converter(value) else getDefault())
              return

            if interpolationStatus[directive] and interpolationStatus[directive][key]
              attrs.$observe key, (value) ->
                updateValue value
                return

            else
              updateValue attrs[key] and $interpolate(attrs[key])(scope.$parent)
            return

          return
    ]
    return


  # HTML templates
  tagsInput.run [
    "$templateCache"
    ($templateCache) ->
      $templateCache.put "ngTagsInput/tags-input.html", "<div class=\"host\" tabindex=\"-1\" ti-transclude-append=\"\"><div class=\"tags\" ng-class=\"{focused: hasFocus}\"><ul class=\"tag-list\"><li class=\"tag-item\" ng-repeat=\"tag in tagList.items track by track(tag)\" ng-class=\"{ selected: tag == tagList.selected }\" ng-click=\"tagList.selected = $index\"><span>{{getDisplayText(tag)}}</span> <a class=\"remove-button\" ng-click=\"tagList.remove($index)\">{{options.removeTagSymbol}}</a></li></ul><input class=\"input\" placeholder=\"{{options.placeholder}}\" tabindex=\"{{options.tabindex}}\" ng-model=\"newTag.text\" ng-change=\"newTagChange()\" ng-trim=\"false\" ng-class=\"{'invalid-tag': newTag.invalid}\" ti-autosize=\"\"></div></div>"
      $templateCache.put "ngTagsInput/auto-complete.html", "<div class=\"autocomplete\" ng-show=\"suggestionList.visible\"><ul class=\"suggestion-list\"><li class=\"suggestion-item\" ng-repeat=\"item in suggestionList.items track by track(item)\" ng-class=\"{selected: item == suggestionList.selected}\" ng-click=\"addSuggestion()\" ng-mouseenter=\"suggestionList.select($index)\" ng-bind-html=\"highlight(item)\"></li></ul></div>"
  ]
  return
)()
