###
# Convert a JSON color-theme to LESS css
###


requires = ['emacs/theme/normalize', 'underscore-min', 'console', 'colors']
require.def 'emacs/theme/less', requires,
(normalize, _, console, colors)->
  _ = if window? then window._ else this._

  buildLess = (buffer, nulls)->
    more = []
    _.each buffer, (atts, selector)->
      more.push "#{selector} {\n"
      _.each atts, (value, attr) ->
        if attr == 'null' || !attr?
          more.push "  #{value}"
        else
          comment = ""
          if !value?
            comment = "//" unless nulls
          more.push "  #{comment}#{attr}: #{value}"
        more.push ";\n"
      more.push "}\n"
    _(more).join ""

  singleFace = (name, attr, value, nulls)->
    buffer = {}
    key = name+':'+attr
    setThemeValue key, value, buffer
    buildLess(buffer, nulls)

  parseTheme = (theme, nulls)->
    theme = normalize(theme)
    buffer = {}
    parseThemeParams theme.params, buffer if theme.params?
    parseThemeParams theme.args, buffer if theme.args?
    parseThemeFaces theme.faces, buffer if theme.faces?
    buildLess(buffer, nulls)

  parseThemeFaces = (faces,buffer)->
    _.each faces, (attrs, name)->
      _.each attrs, (value, attr)->
        if value? && typeof(value) == 'object'
         _.each value, (val, nam)->
           k = "#{name}:#{attr}:#{nam}"
           setThemeValue k, val, buffer
        else
         setThemeValue(name+':'+attr, value, buffer)

  parseThemeParams = (params,buffer)->
    _.each params, (value,key)->
      if value? && typeof(value) == 'object'
        _.each value, (val, name)->
          k = key+':'+name
          setThemeValue k, value, buffer
      else
        setThemeValue key, value, buffer

  setThemeValue = (key,value,buffer)->
    _(_.keys(setters)).detect (pattern)->
      if match = key.match(new RegExp(pattern))
        setter = setters[pattern](match)
        setter.apply this, [value, buffer]
      match

  boxStyle = (value) ->
    ({
     "raised": "outset"
     "sunken": "inset"
     "released-button": "outset"
     "pressed-button": "inset"
     "none": "none"
     "nil": "none"
    })[value]

  cssWarning = (match)->
    (value,buffer)->
      return if !value? || value == 'nil'
      cssSet(".#{match[1]}", "foreground-color", cssColor)(value,buffer)
      cssSet(".inspecting", "border-color",cssColor)(value,buffer)

  cssUnderline = (match)->
    (value,buffer)->
      if value == true || value == 'true' || value == 't'
        cssSet(".#{match[1]}", "border-bottom-style")("solid", buffer)
        cssSet(".#{match[1]}", "border-bottom-width")("thin", buffer)
      else if !value? || value == false || value == 'false' || value == 'nil'
        cssSet(".#{match[1]}", "border-bottom-width")("0px", buffer)
      else if _.isString(value)
        cssSet(".#{match[1]}", "border-bottom-color",cssColor)(value, buffer)
        cssSet(".#{match[1]}", "border-bottom-style")("solid", buffer)
        cssSet(".#{match[1]}", "border-bottom-width")("thin", buffer)

  cssOverline = (match)->
    (value,buffer)->
      if value == true || value == 'true' || value == 't'
        cssSet(".#{match[1]}", "border-top-style")("solid", buffer)
        cssSet(".#{match[1]}", "border-top-width")("thin", buffer)
      else if !value? || value == false || value == 'false' || value == 'nil'
        cssSet(".#{match[1]}", "border-top-width")("0px", buffer)
      else if _.isString(value)
        cssSet(".#{match[1]}", "border-top-color",cssColor)(value, buffer)
        cssSet(".#{match[1]}", "border-top-style")("solid", buffer)
        cssSet(".#{match[1]}", "border-top-width")("thin", buffer)

  cssStrike = (match)->
    (value,buffer)->
      if value == true || value == 'true' || value == 't'
        cssSet(".#{match[1]}", "text-decoration")("line-through", buffer)
      else if !value? || value == false || value == 'false' || value == 'nil'
        cssSet(".#{match[1]}", "text-decoration")("none", buffer)
      else if _.isString(value)
        cssSet(".#{match[1]}", "text-decoration")("line-through", buffer)
        cssSet(".#{match[1]}", "//line-through-color",cssColor)(value, buffer)


  cssFontSize = (value)-> value
  cssFontFamily = (value) -> "\"#{value}\""

  cssColor = (value)->
    if !value? || value == false || value == 'false' || value == 'nil'
      return 'transparent'
    hex = colors.hexByName(value)
    console.debug("COLOR NOT FOUND",value) unless hex
    if hex then hex else value

  cssInherit = (parent)->
    parent = if _.isArray(parent) then parent else [parent]
    parent.map (p) ->
      match = "#{p}".match(/^font-lock-(.*)-face$/)
      if match then ".#{match[1]}" else ".#{p}"
    parent.join(";\n")

  foo = ()->
    if !parents? then return
    if !parents.quote? then parents = parents.quote
    if _.isArray parents
       parents = if(parents[0] == 'quote') then parents.slice(1) else parents
    if _.isString(parents) then parents = [parents]
    if _.isArray(parents)
       parents = _(_(parents).keys().
        concat(_(parents).values())).reject((v)-> v?)
    vals = _(parents).map (parent)->
       match = "#{parent}".match(new RegExp("font-lock-(.*)-face"))
       if(match?) then parent = match[1]
       ".#{parent}"
    vals.join("; ")

  cssSet = (selector,style,conversion)->
    (value, buffer)->
      if _.isFunction(conversion)
        value = conversion.apply(this, [value])
      else if _.isString(conversion)
        if value == true
           value = conversion
        else
           value = null
      atts = (buffer[selector] or= {})
      atts[style] = value

  setters = {
   "^background-color$": (match)->
     cssSet('.default', 'background-color', cssColor)

   "^foreground-color$": (match)->
     cssSet('.default', 'color', cssColor)

   "^font-lock-(warning)-face:foreground$": (match)->
     cssWarning(match)

   "^font-lock-(.*)-face:background$": (match)->
     cssSet('.'+match[1], 'background-color', cssColor)

   "^font-lock-(.*)-face:foreground$": (match)->
     cssSet('.'+match[1], 'color', cssColor)

   "^font-lock-(.*)-face:family$": (match)->
     cssSet('.'+match[1], 'font-family', cssFontFamily)

   "^font-lock-(.*)-face:foundry$": (match)->
     cssSet('.'+match[1], '//font-foundry')

   "^font-lock-(.*)-face:width$": (match)->
     cssSet('.'+match[1], 'font-stretch')

   "^font-lock-(.*)-face:height$": (match)->
     cssSet('.'+match[1], 'font-size', cssFontSize)

   "^font-lock-(.*)-face:bold$": (match)->
     cssSet('.'+match[1], 'font-weight', 'bold')

   "^font-lock-(.*)-face:italic$": (match)->
     cssSet('.'+match[1], 'font-style', 'italic')

   "^font-lock-(.*)-face:underline$": (match)->
     cssUnderline(match)

   "^font-lock-(.*)-face:overline$": (match)->
     cssOverline(match)

   "^font-lock-(.*)-face:strike-through$": (match)->
     cssStrike(match)

   "^font-lock-(.*)-face:slant$": (match)->
     cssSet('.'+match[1], 'font-style')

   "^font-lock-(.*)-face:weight$": (match)->
     cssSet('.'+match[1], 'font-weight')

   "^font-lock-(.*)-face:box:color$": (match)->
     cssSet '.'+match[1], 'border-color', cssColor

   "^font-lock-(.*)-face:box:style$": (match)->
     cssSet '.'+match[1], 'border-style', boxStyle

   "^font-lock-(.*)-face:box:line-width$": (match)->
     cssSet('.'+match[1], 'border-width')


   "^font-lock-(.*)-face:inherit$": (match)->
     cssSet('.'+match[1], null, cssInherit)

   "^(.*):background$": (match)->
     cssSet('.'+match[1], 'background-color', cssColor)

   "^(.*):foreground$": (match)->
     cssSet('.'+match[1], 'color', cssColor)

   "^(.*):family$": (match)->
     cssSet('.'+match[1], 'font-family', cssFontFamily)

   "^(.*):foundry$": (match)->
     cssSet('.'+match[1], '//font-foundry')

   "^(.*):width$": (match)->
     cssSet('.'+match[1], 'font-stretch')

   "^(.*):height$": (match)->
     cssSet('.'+match[1], 'font-size', cssFontSize)

   "^(.*):bold$": (match)->
     cssSet('.'+match[1], 'font-weight', 'bold')

   "^(.*):italic$": (match)->
     cssSet('.'+match[1], 'font-style', 'italic')

   "^(.*):underline$": (match)->
     cssUnderline(match)

   "^(.*):overline$": (match)->
     cssOverline(match)

   "^(.*):strike-through$": (match)->
     cssStrike(match)

   "^(.*):slant$": (match)->
     cssSet('.'+match[1], 'font-style')

   "^(.*):weight$": (match)->
     cssSet('.'+match[1], 'font-weight')

   "^(.*):box:color$": (match)->
     cssSet '.'+match[1], 'border-color', cssColor

   "^(.*):box:style$": (match)->
     cssSet '.'+match[1], 'border-style', boxStyle

   "^(.*):box:line-width$": (match)->
     cssSet('.'+match[1], 'border-width')

   "^(.*):inherit$": (match)->
     cssSet('.'+match[1], null, cssInherit)

   "^region$": (match)->
     cssSet('.region','background-color', cssColor)

   "^(.*)$": (match)-> (value,buffer)->
     cssSet('unknown', "// #{match[1]}")(value,buffer)

  }

  parseTheme.face = singleFace
  parseTheme
