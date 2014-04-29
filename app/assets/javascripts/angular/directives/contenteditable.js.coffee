angular.module("contenteditable", []).directive "contenteditable", [
  "$timeout"
  ($timeout) ->
    return (
      restrict: "A"
      require: "?ngModel"
      link: (scope, element, attrs, ngModel) ->

        # don't do anything unless this is actually bound to a model
        return  unless ngModel

        # options
        opts = {}
        angular.forEach [
          "stripBr"
          "noLineBreaks"
          "selectNonEditable"
          "moveCaretToEndOnChange"
        ], (opt) ->
          o = attrs[opt]
          opts[opt] = o and o isnt "false"
          return


        # view -> model
        element.bind "input", (e) ->
          scope.$apply ->
            html = undefined
            html2 = undefined
            rerender = undefined
            html = element.html()
            rerender = false
            html = html.replace(/<br>$/, "")  if opts.stripBr
            if opts.noLineBreaks
              html2 = html.replace(/<div>/g, "").replace(/<br>/g, "").replace(/<\/div>/g, "")
              if html2 isnt html
                rerender = true
                html = html2
            ngModel.$setViewValue html
            ngModel.$render()  if rerender
            if html is ""

              # the cursor disappears if the contents is empty
              # so we need to refocus
              $timeout ->
                element[0].blur()
                element[0].focus()
                return

            return

          return


        # model -> view
        oldRender = ngModel.$render
        ngModel.$render = ->
          el = undefined
          el2 = undefined
          range = undefined
          sel = undefined
          oldRender()  unless not oldRender
          element.html ngModel.$viewValue or ""
          if opts.moveCaretToEndOnChange
            el = element[0]
            range = document.createRange()
            sel = window.getSelection()
            if el.childNodes.length > 0
              el2 = el.childNodes[el.childNodes.length - 1]
              range.setStartAfter el2
            else
              range.setStartAfter el
            range.collapse true
            sel.removeAllRanges()
            sel.addRange range
          return

        if opts.selectNonEditable
          element.bind "click", (e) ->
            range = undefined
            sel = undefined
            target = undefined
            target = e.toElement
            if target isnt this and angular.element(target).attr("contenteditable") is "false"
              range = document.createRange()
              sel = window.getSelection()
              range.setStartBefore target
              range.setEndAfter target
              sel.removeAllRanges()
              sel.addRange range
            return

        return
    )
]
