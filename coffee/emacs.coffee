# ** emacs.coffee
requires = [
  'console',
  'colors',
  'emacs/theme/normalize',
  'emacs/theme/less',
  'emacs/theme/lisp'
]
require.def 'emacs', requires,
(console, colors, normalize, lezz, lisp) ->
  [_, $, JSON] = [window._, window.$, window.JSON]

  emacs = {}
  files = null
  themes = {}
  always = null
  base_light = null
  base_dark = null
  cumulative = false
  current_theme = null

  gup = (name)->
   regexS = "[\\?&]"+name+"=([^&#]*)";
   regex = new RegExp ( regexS );
   tmpURL = window.location.href;
   results = regex.exec( tmpURL )
   if( results == null )
     null
   else
     results[1]

  download = (url,callback)->
    data = null
    $.ajax
      async: false
      url: '/download/'+url
      success: if callback? then callback else (d)->(data = d)
    data

  linkHref = (name)-> $("link[rel='#{name}']").attr('href')

  metaContent = (name)-> $("meta[name='#{name}']").attr('content')

  collection = (name)->
    if themes[name]
      col = themes[name]
    else
      col = themes[name] = download(linkHref "themes-#{name}")
      themes.all or= {}
      themes.all = $.extend(true, themes.all, col)
      themes.all[""] = "Currently known themes"
    col

  emacs.loadGistTheme = ()->
    url = prompt("Load a color-theme from GitHub Gist.\nEnter Gist ID or URL")
    return unless url?
    match = url.match(/\d+/)
    return if !match || !match[0]
    downloadGistTheme match[0]

  downloadGistTheme = (gist)->
    json_uri = "http://gist.github.com/raw/#{gist}/json"
    less_uri = "http://gist.github.com/raw/#{gist}/less"
    model = normalize(download("text/json/"+json_uri))
    meta =
      model: model
      name: model.name
      mode: model.params["background-mode"]
      desc: model.docs
      json: json_uri
      less: less_uri
    themes.all[model.name] = meta if themes.all?
    meta


  downloadLocalTheme = (name)->
    lookup = ()->
      meta = null
      _.detect arguments, (coll)->
        if collection(coll)? && collection(coll)[name]
          meta = collection(coll)[name]
          meta.name = name
          meta.coll = coll
          meta.json or= "themes/#{coll}/json/#{name}.json"
          meta.less or= "themes/#{coll}/less/#{name}.less"
          meta.model or= normalize(download(meta.json))
        meta
      meta
    lookup('base', 'standard', 'featured', 'contributed')

  loadBase = ()->
    always = download(linkHref 'less-always')
    base_light = download(linkHref 'less-light')
    base_dark = download(linkHref 'less-dark')

    _.defer ()-> showThemeList('standard')

    _.defer ()-> setInitialTheme()

    displayFileList()
    $('#files a:first').click()

  setupThemeSearch = ()->
    $('#filter').liveUpdate('#themes .list .theme','#themes .results')

  displayFileList = ()->
    files = download(linkHref 'files-json')
    buildFileList(1, files, $('#files'))
    a = $('#files a.speedbar-file-face,
           #files a.speedbar-tag-face')
    a.click (event)->
      event.preventDefault()
      $('#files .speedbar-selected-face').
        removeClass('speedbar-selected-face')
      $(this).addClass('speedbar-selected-face')
      loadFile($(this).attr('href').substring(1))
    d = $('#files a.speedbar-directory-face,
           #files a.speedbar-button-face')
    d.click (event)->
      event.preventDefault()
      dir = $(this).attr('href').substring(1);
      button = $("#files .speedbar-button-face[href='##{dir}']")
      child = $("#files div[dir = '#{dir}']")
      if button.text() == '<+>'
        child.show()
        button.text('<->')
      else
        child.hide()
        button.text('<+>')

  loadFile = (file)->
    path = file.split('/')
    name = path[path.length-1]
    file = _.reduce path, files, (fs,f)-> fs[f]
    if file.file
      $('#current-buffer').load("/files/#{file.file}")
    if file.js
      loc = file.js.split('#')
      if loc.length == 1
        $('head').append "
          <script type='text/javascript' src='/files/#{loc[0]}'/>"
      else
        $('head').append "
          <script type='text/javascript' lang='javascript'>
            require(['#{loc[0]}'], function(#{loc[0]}){
              #{loc[0]}.#{loc[1]}();
            });
          </script>
        "
    if file.file
     modes = [file.major || '']
     modes = modes.concat(file.minors || [])
     modeline = """
     <span class='mode-line-buffer-id'>#{name}</span>
     %7 L1 (#{modes.join(' ')})
     """
     $('#modeline-rest').html(modeline)

  emacs.selectRandomTheme = ()->
    names = $("#themes .theme:visible a")
    rand = Math.floor(Math.random()*names.length)
    name = $(names[rand])
    name.click()
    name.focus()

  buildFileList = (level, files, into, parent)->
    parent = parent || ""
    _.each files, (value, key)->
      if _.isString(value.file) || _.isString(value.js)
        face = if key[0] == '*' then 'tag' else 'file'
        into.append "
        <span style='padding-left:#{level}em'></span>
        <a href='##{parent}#{key}' title='#{value.title}'
           parent='#{parent}' class='speedbar-#{face}-face'>#{key}</a>
        <br/>
        "
      else
        into.append "
        <div>
          <span style='padding-left:#{level}em'></span>
          <a href='##{parent}#{key}' class='speedbar-button-face'>&lt;+&gt;</a>
          <a href='##{parent}#{key}' class='speedbar-directory-face'>#{key}</a>
          <div dir='#{parent}#{key}' style='display:none'></div>
        </div>
        "
        subdir = $("#files div[dir='#{parent}#{key}']")
        buildFileList(level+1, value, subdir, key+"/")


  showThemeList = (name)->
    coll = collection(name)
    displayThemeList coll
    $('span.theme-coll').text name
    $('span.theme-coll-desc').text coll[""] || ""
  displayThemeList = (themes)->
    $('#themes .list').html($('#themes .resets').html())
    template = _.template "
      <div class='theme'>
       <div class='name'>
        <a class='default bold' href='#<%=name%>'><%=name.replace(/^color-theme-/, '')%></a>
       </div>
       <div class='desc'>
         <%=desc[0]%>
         <div>
           <%=desc.slice(1).join('\n') %>
         </div>
       </div>
      </div>
    "
    _.each themes, (meta, name)->
       return if name == ""
       meta.name = name
       html = template(meta)
       $('#themes .list').append(html)
    setupThemeSearch()

  setInitialTheme = ()->
    if /#\d+/.test(location.hash)
      gist = location.hash.substring(1)
      meta = downloadGistTheme gist
      hash = gist
    else if "#{location.hash}".length > 1
      hash = location.hash.substring(1)
      meta = downloadLocalTheme hash
    else
      meta = downloadLocalTheme metaContent('theme-default')
      hash = meta.model.name
    installTheme meta, true, hash

  installTheme = (meta, clear, hash)->
    hash or= meta.model.name
    base = if meta.mode == 'dark' then base_dark else base_light

    unless meta.css
      if meta.less
        meta.css = download(meta.less)
      else
        meta.css = lezz(meta.model)

    parent = {}
    parent = current_theme if !clear && current_theme

    theme = $.extend(true, {}, parent, meta)

    $('style[emacs]').remove() if clear

    css = ["/*** LESS css for #{theme.name} (#{theme.mode}) ***/",
           "/*** Generated on #{new Date()} from #{window.location} ***/"]
    if clear
      css.push "/*** ALWAYS ***/", always, "/*** ALWAYS:END ***/"
      css.push "/*** BASE ***/", base, "/*** BASE:END ***/"
    css.push "/*** THEME #{theme.name} ***/", meta.css, "/*** THEME:END **/"
    css = css.join("\n")

    $('<style>', {type: 'text/less', emacs: theme.name}).
      html(css).appendTo('head')

    try
       less.refresh()
    catch e
       console.error('Error loading theme', e)
       throw e

    current_theme = theme

    $('.theme-name').text theme.name
    $('.theme-name').val theme.name
    faceNames = $('#faceNames')
    _.each _.keys(theme.model.faces).sort(), (name)->
       faceNames.append "<option class='#{name}'>#{name}</option>"

    customizeFace 'default'
    $('input.theme-name').trigger 'themeChanged'
    $('input.theme-name').trigger 'themeLoaded', hash

  customizeFace = (name)->
    return unless name
    $('#faceNames').val(name)
    match = name.match(/font-lock-(.*)-face/)
    cls = if match then match[1] else name
    sample = $('#faceSample')
    sample.attr('class','').addClass(cls).text(name)
    fg = sample.css('color')
    bg = sample.css('background-color')
    def = $('<span class="default">')
    if bg == 'transparent'
      bg = def.css('background-color')
    setPickColor 'foreground',  colors.cssRgbToHex(fg)
    setPickColor 'background', colors.cssRgbToHex(bg)
    face = current_theme.model.faces[name] || {}
    $('.faceProps [name="family"]').val face['family']
    $('.faceProps [name="foundry"]').val face['foundry']
    $('.faceProps [name="width"]').val face['width']
    $('.faceProps [name="height"]').val face['height']
    $('.faceProps [name="slant"]').val face['slant']

    colored = (selName)->
      ary = selName.split(':')
      val = face[ary[0]]
      val = val[ary[1]] if ary.length > 1 && val?
      sel = $(".faceProps select[name='#{selName}']")
      pik = $(".faceProps .pickcolor[name='#{selName}']")
      pik.attr('style', '')
      if val == true || val == 'true'
        sel.val 'on'
      else if val == false || !val? || val == 'false'
        sel.val 'off'
      else
        sel.val 'colored'
        pik.css('background-color', val)

    colored 'underline'
    colored 'overline'
    colored 'strike-through'

    box_style = {
      "released-button": "raised"
      "pressed-button": "sunken"
      "null": "none"
      "undefined": "none"
      "false": "none"
      "": "none"
    }["#{face.box.style if face.box?}"]
    $('.faceProps [name="box:style"]').val box_style
    box_width = face.box['line-width'] if face.box?
    $('.faceProps [name="box:line-width"]').val box_width

    colored 'box:color'

  setFaceAttribute = (name, value, faceName)->
    return unless current_theme
    $('input.theme-name').trigger 'themeChanged'
    faceName or= $('#faceNames').val()
    face = (current_theme.model.faces[faceName] or= {})
    if name.match(/:/)
      set = (v)->
        match = name.split(':')
        here = (face[match[0]] or= {})
        here[match[1]] = v
    else
      set = (v)-> face[name] = v
    set value
    css = lezz.face(faceName, name, value)
    emacs = "#{faceName}:#{name}"
    $("head style[emacs='#{emacs}']").remove()
    $('head').append "
    <style emacs='#{emacs}' type='text/css'>
      #{css}
    </style>
    "



  setPickColor = (name, color, value)->
    return unless color?
    pkr = $(".faceProps .pickcolor[name='#{name}']")
    pkr.css('background-color', color)
    pkr.ColorPickerSetColor(color)
    target = $(pkr.attr('target'))
    if target.is('select, input')
       target.val (value || color)
    else
       target.text (value || color)

  setFaceColor = (fg, color, updatePicker)->
    return unless current_theme
    $('input.theme-name').trigger 'themeChanged'
    attr = if fg then 'foreground' else 'background'
    faceName = $('#faceNames').val()
    current_theme.model.faces[faceName] or= {}
    css = if fg then 'color' else 'background-color'
    current_theme.model.faces[faceName][attr] = color
    emacs = "#{faceName}:#{attr}"
    selector = faceName
    match = faceName.match /font-lock-(.*)-face/
    if match then selector = match[1]
    $("head style[emacs='#{emacs}']").remove()
    $('head').append "
    <style emacs='#{emacs}' type='text/css'>
      .#{selector} { #{css}: #{color}; }
    </style>
    "
    $('#faceNames').css(css, color) if faceName == 'default'

  faceNameForElement = (elem)->
    elem = $(elem)
    classes = (elem.attr('class') || '').split(/ +/)
    found = null
    _.detect classes.slice(0), (cls)->
      found = cls if current_theme.model.faces[cls]
      cls = "font-lock-#{cls}-face" unless found
      found = cls if current_theme.model.faces[cls]
      found
    if found
      found
    else if elem.parent().length > 0
      faceNameForElement elem.parent()
    else
      'default'

  setCumulativeState = (state)->
       cumulative = state
       if cumulative
         $('span.cumulative-state').text '(nil)'
       else
         $('span.cumulative-state').text '(non-nil)'

  emacs.init = ()->
    console.debug "Loading emacs"
    setCumulativeState(false)

    $('#faceNames').change ()-> customizeFace $(this).val()

    _.each $('.faceProps .pickcolor'), (pick)->
      pick = $(pick)
      name = pick.attr('name')
      selector = pick.attr('target')
      target = $(selector)
      pick.ColorPicker
        onChange: (hsb, hex, rgb)->
          pick.css('background-color', '#'+hex)
          target.trigger('colorChange', '#'+hex)

    $('.faceProps span[name="foreground"]').bind
      colorChange: (event, color) ->
        $(this).text color
        setFaceColor(true, color)

    $('.faceProps span[name="background"]').bind
      colorChange: (event, color) ->
        $(this).text color
        setFaceColor(false, color)

    $('.faceProps input[name]').change ()->
      name = $(this).attr('name')
      val = $(this).val() || ''
      val = null if val == ''
      setFaceAttribute(name, val)

    $('.faceProps select[name]').bind
      colorChange: ()->
       $(this).val 'colored'
       $(this).trigger 'change'

    $('.faceProps select[name]').change ()->
      name = $(this).attr('name')
      val = $(this).val() || ''
      picker = $(".pickcolor[name='#{name}']")
      if val.match(/^(on|true|yes)$/i)
        val = true
        picker.attr('style', '')
      else if val == '' || val.match(/^(off|false|no)$/i)
        val = false
        picker.attr('style', '')
      else if val == 'colored'
        val = colors.cssRgbToHex picker.css('background-color')
      setFaceAttribute(name, val)

    $('button[href="#toggle-cumulative"]').click (event)->
       event.preventDefault()
       setCumulativeState(!cumulative)

    $('#themes a').live 'click', (event)->
       event.preventDefault()
       $('#themes .secondary-selection').
          removeClass('secondary-selection')
       $(this).parent().parent().find('.desc').
          addClass('secondary-selection')
       clear = !cumulative
       name = $(this).attr('href').substring(1)
       if name == 'reset-light'
         clear = true
         name = metaContent('theme-light')
       else if name == 'reset-dark'
         clear = true
         name = metaContent('theme-dark')
       theme = downloadLocalTheme(name)
       installTheme theme, clear

    $('.save').live 'click', (event)->
       event.preventDefault()
       loc = "#{location.protocol}//#{location.host}#{location.pathname}"
       gen = "Generated with #{loc} on #{new Date()}"
       current_theme.model.docs.unshift gen
       html = lisp current_theme.model,
          open: (cls)->
            if cls == 'pre'
              "<pre id='dump-theme>'"
            else if cls == 'doc'
              "<span id='doc' class='doc'>"
            else
              "<span class='#{cls}'>"
          close: (cls)->
            cls or= "span"
            "</#{cls}>"
          header: (buffer, theme, htmlized)->
            buffer.push "<span class='comment'>"
            buffer.push """
;; <span class='theme-name'>#{current_theme.model.name}</span> #{gen}
;; You can edit the theme name or the documentation by hovering over them.
;; Be sure to add your name and email if you want to contribute this theme.
;;
;; <span id='loading'>Creating gist.. please wait</span>
;; <span id='reload'>
;;   <span class='custom-invalid'>Warning: theme has changed</span>
;;   <button class='save custom-button'>(revert-buffer)</button>
;; </span>
;; <span id='shares'>
;;   <a id='gist-download-el' class='link'>Download</a> | <a id='gist-load' class='link'>Permalink</a> | <a id='gist-link' class='link' target='_blank'>Gist</a> | <a id='share-this' class='link'>Share</a> | <a id='contrib' class='link' title='Send a mail to vic.borja@gmail.com with the gist id for this theme'>Contribute</a>
;; </span>
            """
            buffer.push "</span>"
       $('#current-buffer').html(html)
       _.defer ()->
         $.ajax
          type: 'POST'
          url: '/gist'
          data:
            name: current_theme.model.name
            docs:  current_theme.model.docs.join("\n")
            lisp: lisp current_theme.model
            json: JSON.stringify current_theme.model
            less: lezz current_theme.model
          success: (gist) ->
            location.hash = gist
            name = current_theme.model.name
            $('#gist-link').
              attr('href', "http://gist.github.com/#{gist}")
            $('#gist-download-el').
              attr('href', "/gist/#{gist}/elisp/#{name}.el")
            $('#gist-load').attr('href', "/##{gist}")
            $('#contrib').attr('href', "mailto:vic.borja@gmail.com?subject=color-theme-select contribution&body=Please include the theme saved in the following gist: #{gist}")
            if stWidget?
              st = stWidget.addEntry({
                 service: 'sharethis',
                 element: $('#share-this')[0],
                 title: "Emacs color-theme: #{name}",
                 url: "##{gist}"
                }, {button: true})
            $('#share-this').text("Share #{name}")
            $('#shares').show()
            $('#loading').hide()
       old_name = null
       $('.function-name > .theme-name').live 'mouseover', (event)->
         event.preventDefault()
         text = $('<input>').addClass('function-name').addClass('flatInput')
         old_name = $(this).text()
         text.val old_name
         $(this).replaceWith(text)
         text.focus()
       $('input.function-name').live 'mouseout', (event)->
         span = $('<span>').addClass('theme-name')
         txt = $(this).val()
         span.text txt
         $(this).replaceWith(span)
         if old_name != txt
           current_theme.name = txt
           current_theme.model.name = txt
           $('span.theme-name').text txt
           $('input.theme-name').trigger 'themeChanged'

       old_doc = null
       $('span#doc').live 'mouseover', (event)->
         event.preventDefault()
         area = $('<textarea id="doc" cols="80" rows="5" />')
         area.addClass('flatInput').addClass('doc')
         area.css('border-width', 'thin').css('border-style', 'dotted')
         old_doc = $(this).text()
         area.val old_doc
         $(this).replaceWith(area)
         area.focus()
       $('textarea#doc').live 'mouseout', (event)->
         event.preventDefault()
         span = $('<span id="doc" class="doc" />')
         val = $(this).val()
         val = "\"Generated at #{new Date()}\"" if val == ''
         span.text val
         $(this).replaceWith(span)
         if old_doc != val
           $('input.theme-name').trigger 'themeChanged'

    $('a.select-face-at-point').click (event)->
      event.preventDefault()
      $('.frame').addClass('select_face_at_point')

    $('.select_face_at_point *').live 'hover', (event)->
      event.preventDefault()
      if event.type == 'mouseover'
        $(this).addClass 'face-at-point'
      else
        $(this).removeClass 'face-at-point'

    $('.select_face_at_point .face-at-point').live 'click', (event)->
      event.preventDefault()
      $('.frame').removeClass('select_face_at_point')
      $(this).removeClass('face-at-point')
      customizeFace faceNameForElement(this)

    $('a.list-faces-display').click (event)->
      event.preventDefault()
      $('#current-buffer').html "
        <h2>Faces display for #{current_theme.model.name}</h2>
        <h5 class='widget-documentation'>
          To customize a face click on its name.
        </h5>
      "
      sample = "aeiou 01234567890 ABCDEF ~!@#$%^&*()[]{}="
      _.each _.keys(current_theme.model.faces).sort(), (name)->
        match = name.match(/^font-lock-(.*)-face$/)
        if match
          cls = match[1]
        else
          cls = name
        $('#current-buffer').append "
        <div class='listedface'>
          <div class='name'>
           <a class='button'>#{name}</a>
          </div>
          <div class='desc'>
           <span class='#{cls}'>#{sample}</span>
          </div>
        </div>
        "
      $('.listedface a.button').click (event)->
        event.preventDefault()
        customizeFace $(this).text()

    $('#themes select.theme-coll').change (event)->
        showThemeList($(this).val())

    $('input.theme-name').live 'keyup', (event)->
        name = $(this).val()
        current_theme.name = name
        current_theme.model.name = name
        $('span.theme-name').text name
        if event.keyCode == 13
          $('#save').trigger('click')
          $('input.theme-name').trigger 'themeLoaded'
        else
          $('input.theme-name').trigger 'themeChanged'

    $('input.theme-name').bind
      themeLoaded: (event, hash)->
        $('span.modified').text '%%'
        location.hash = hash
      themeChanged: (event)->
        $('span.modified').text '**'
        $('#current-buffer #shares').hide()
        $('#current-buffer #reload').show()


    loadBase()
    console.debug "Loaded emacs, current theme: ", current_theme

  emacs

