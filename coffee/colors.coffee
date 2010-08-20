# Color functions

self =
  cssRgbToHex: (str)->
    return str if !str?
    ary = str.match(/\d+/g)
    return str if ary == null
    hex = _.map ary, (c)->
      c = parseInt(c).toString(16)
      if c.length == 1 then "0#{c}" else c
    '#'+hex.join('')

  rgbiToHex: (rgbi)->
    ary = rgbi.replace(/rgbi:/, '').split('/')
    hex = _.map ary, (c)->
      c = parseInt(c).toString(16)
      if c.length == 1 then "0#{c}" else c
    '#'+hex.join('')

  inverseHex: (str)->
    ary = str.match(/[0-9A-F]{2}/gi)
    return str if ary == null
    hex = _.map ary, (c)->
      c = (255 - parseInt(c, 16)).toString(16)
      if c.length == 1 then "0#{c}" else c
    '#'+hex.join('')

  hexByNameInObject: (name, colors)->
    return null if !name? || name == ''
    return name if name.substring(0,1) == '#'
    name = name.replace(/ +/, '').toLowerCase()
    colors[name] || colors[name.replace(/gray/g, 'grey')]

  colorDbs: ['X11', 'CNE', 'X11', 'WWW', 'Crayola', 'Mozilla', 'IE']

  colorMaps: []

  hexByName: (name)->
    return null if !name?
    name = name.replace(/[ <>{}[\]]+/g, '')
    return null if name == ''
    return name if name.substring(0,1) == '#'
    return "##{name}" if /^[0-9A-F]{6}$/i.test(name)
    return self.rgbiToHex(name) if /^rgbi:[\d\.\/]+$/.test(name)
    i = 0
    hex = null
    len = self.colorMaps.length
    while !hex? && i < len
      map = self.colorMaps[i]
      hex = self.hexByNameInObject(name, map)
      i += 1
    hex

require.def 'colors', self

