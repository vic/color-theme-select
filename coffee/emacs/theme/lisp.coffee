###
# Convert a JSON color-theme to emacs-lisp
#
###


requires = ['emacs/theme/normalize', 'underscore-min', 'console']
require.def 'emacs/theme/lisp', requires,
(normalize, _, console)->
  _ = window._

  theme2lisp = (json, htmlized)->
    json = normalize(json)
    if !htmlized?
      htmlized =
        open: ()-> ""
        close: ()-> ""
    else if htmlzied == true
      htmlzied =
        open: (cls) -> "<span class=\"#{cls}\">"
        close: ()-> "</span>"
    htmlized.open('pre')+
      parseTheme(json, htmlized)+
      htmlized.close('pre')

  parseTheme = (theme,htmlized)->
    buffer = []
    if _.isFunction(htmlized.header)
       htmlized.header(buffer, theme, htmlized)
    else
       buffer.push htmlized.open('comment')
       buffer.push ";; -*- emacs-lisp -*-"
       buffer.push ";;"
       buffer.push ";;"
       buffer.push ";; name: #{theme.name}"
       buffer.push ";; date: #{new Date()}"
       buffer.push ";;"
       buffer.push ";;"
       buffer.push ";; To use this theme save this code into a"
       buffer.push ";; file named #{theme.name}.el and place it"
       buffer.push ";; in a directory in your load-path"
       buffer.push ";;"
       buffer.push ";;    (require '#{theme.name})"
       buffer.push ";;    (#{theme.name})"
       buffer.push ";;"
       buffer.push htmlized.close()
       buffer.push ""
    buffer.push "("+htmlized.open('keyword')+'defun'+htmlized.close()+' '+htmlized.open('function-name')+htmlized.open('theme-name')+theme.name+htmlized.close()+htmlized.close()+' ()'
    buffer.push "  "+htmlized.open('doc')+'"'+_(theme.docs).join("  \n")+'"'+htmlized.close()
    buffer.push "  (interactive)"
    buffer.push "  (color-theme-install)"
    buffer.push "    \'("+htmlized.open('theme-name')+theme.name+htmlized.close()
    parseParams "      ",theme,theme.params, buffer,htmlized
    parseParams "      ",theme,theme.args,buffer,htmlized
    parseFaces  "      ",theme,theme.faces,buffer,htmlized
    buffer.push "     )"
    buffer.push "  )"
    buffer.push ")"
    _(buffer).join("\n")

  parseFaces = (space,theme,faces,buffer,htmlized)->
    bfs = {}
    _.each faces, (attrs,name)->
     _.each attrs, (value,attr)->
       vls = bfs[name] || []
       bfs[name] = vls
       vls.push htmlized.open('builtin')+':'+attr+htmlized.close()
       vls.push parseValue(value, attr, htmlized)
    _.each bfs, (attrs,name)->
       buffer.push space+
         '('+name+
         '  (('+htmlized.open('keyword')+'t'+htmlized.close()+' ('+
         _(attrs).join(' ')+
         ')))'+
         ')'

  parseParams = (space,theme,params,buffer,htmlized)->
    buffer.push space+'('
    if params?
      _.each params, (value,name)->
        buffer.push space+' ('+name+' . '+parseValue(value, name, htmlized)+')'
    buffer.push space+')'

  box = (obj, htmlized)->
    if !obj?
      return htmlized.open('keyword')+'nil'+htmlized.close()
    buffer = []
    buffer.push '('
    _.each obj, (value,key)->
      buffer.push htmlized.open('builtin')+':'+key+htmlized.close()
      buffer.push parseValue(value,key,htmlized)
    buffer.push ')'
    _(buffer).join(' ')

  identity = (i)-> i
  valueMutator =
    "stiple": identity
    "height": identity
    "width": identity
    "weight": identity
    "inherit": identity
    "style": identity
    "line-width": identity
    "slant": identity
    "box": box

  parseValue = (value,key,htmlized)->
    if !value? || value == 'false' || value == false
      return htmlized.open('keyword')+'nil'+htmlized.close()
    if value == 'true' || value == true
      return htmlized.open('keyword')+'t'+htmlized.close()
    mutator = valueMutator[key]
    if mutator
      return mutator(value,htmlized)
    if _.isString(value)
      return htmlized.open('string')+'"'+value+'"'+htmlized.close()
    value

  theme2lisp
