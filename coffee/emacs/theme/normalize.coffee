###
# Normalize a JSON color-theme as returned by emacs' json-encode
# to a more usable format.
###

requires = ['underscore-min', 'console']
require.def 'emacs/theme/normalize', requires,
(_, console)->
  _ = if window? then window._ else this._

  normalize = (json)=>
    if json.params? then return json
    theme =
      name: json.data[0]
      params: json.data[1]
      docs: json.docs
      args: {}
      faces: {}
    faces = []
    unless _.isArray json.data[2]
      theme.args = json.data[2]
      faces = json.data.slice(3)
    else
      faces = json.data.slice(2)
    _.each faces, (face)->
      name = face[0]
      spec = face[1]['true']
      first = null
      for all first,value of spec
        value
      if !first? || first == 'null'
        return
      ary = [first].concat(spec[first])
      for i in [0..ary.length] by 2
        key = ary[i]
        value = ary[i+1]
        attrs = (theme.faces[name] or= {})
        if _.isArray(value)
          attrs[key] = {}
          for j in [0..value.length] by 2
            attrs[key][value[j]] = value[j+1]
        else value? && if typeof(value) == 'object' &&
          _.keys(value).length == 1 && _.isArray(_.values(value)[0])
          a = _.keys(value).concat _.values(value)
          h = {}
          for j in [0..a.length] by 2
            h[a[j]] = h[a[j+1]] if h[a[j+1]]?
          attrs[key] = h
        else if value?
          attrs[key] = value
    theme

  # The module object
  normalize

