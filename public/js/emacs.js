(function() {
  var requires;
  requires = ['console', 'colors', 'emacs/theme/normalize', 'emacs/theme/less', 'emacs/theme/lisp'];
  require.def('emacs', requires, function(console, colors, normalize, lezz, lisp) {
    var $, JSON, _, _a, always, base_dark, base_light, buildFileList, collection, cumulative, current_theme, customizeFace, displayFileList, displayThemeList, download, downloadGistTheme, downloadLocalTheme, emacs, faceNameForElement, files, installTheme, linkHref, loadBase, loadFile, metaContent, setCumulativeState, setFaceAttribute, setFaceColor, setInitialTheme, setPickColor, setupThemeSearch, showThemeList, themes;
    _a = [window._, window.$, window.JSON];
    _ = _a[0];
    $ = _a[1];
    JSON = _a[2];
    emacs = {};
    files = null;
    themes = {};
    always = null;
    base_light = null;
    base_dark = null;
    cumulative = false;
    current_theme = null;
    download = function(url, callback) {
      var data;
      data = null;
      $.ajax({
        async: false,
        url: '/download/' + url,
        success: (typeof callback !== "undefined" && callback !== null) ? callback : function(d) {
          return (data = d);
        }
      });
      return data;
    };
    linkHref = function(name) {
      return $("link[rel='" + (name) + "']").attr('href');
    };
    metaContent = function(name) {
      return $("meta[name='" + (name) + "']").attr('content');
    };
    collection = function(name) {
      var col;
      if (themes[name]) {
        col = themes[name];
      } else {
        col = (themes[name] = download(linkHref("themes-" + (name))));
        themes.all || (themes.all = {});
        themes.all = $.extend(true, themes.all, col);
        themes.all[""] = "Currently known themes";
      }
      return col;
    };
    emacs.loadGistTheme = function() {
      var match, url;
      url = prompt("Enter Gist ID or URL");
      match = url.match(/\d+/);
      if (!(match)) {
        return null;
      }
      return downloadGistTheme(match[0]);
    };
    downloadGistTheme = function(gist) {
      var _b, json_uri, less_uri, meta, model;
      json_uri = ("http://gist.github.com/raw/" + (gist) + "/json");
      less_uri = ("http://gist.github.com/raw/" + (gist) + "/less");
      model = normalize(download("text/json/" + json_uri));
      meta = {
        model: model,
        name: model.name,
        mode: model.params["background-mode"],
        desc: model.docs,
        json: json_uri,
        less: less_uri
      };
      if (typeof (_b = themes.all) !== "undefined" && _b !== null) {
        themes.all[model.name] = meta;
      }
      return meta;
    };
    downloadLocalTheme = function(name) {
      var lookup;
      lookup = function() {
        var meta;
        meta = null;
        _.detect(arguments, function(coll) {
          var _b;
          if ((typeof (_b = collection(coll)) !== "undefined" && _b !== null) && collection(coll)[name]) {
            meta = collection(coll)[name];
            meta.name = name;
            meta.coll = coll;
            meta.json || (meta.json = ("themes/" + (coll) + "/json/" + (name) + ".json"));
            meta.less || (meta.less = ("themes/" + (coll) + "/less/" + (name) + ".less"));
            meta.model || (meta.model = normalize(download(meta.json)));
          }
          return meta;
        });
        return meta;
      };
      return lookup('base', 'standard', 'featured', 'contributed');
    };
    loadBase = function() {
      always = download(linkHref('less-always'));
      base_light = download(linkHref('less-light'));
      base_dark = download(linkHref('less-dark'));
      _.defer(function() {
        return showThemeList('standard');
      });
      _.defer(function() {
        return setInitialTheme();
      });
      displayFileList();
      return $('#files a:first').click();
    };
    setupThemeSearch = function() {
      return $('#filter').liveUpdate('#themes .list .theme', '#themes .results');
    };
    displayFileList = function() {
      var a, d;
      files = download(linkHref('files-json'));
      buildFileList(1, files, $('#files'));
      a = $('#files a.speedbar-file-face, \
#files a.speedbar-tag-face');
      a.click(function(event) {
        event.preventDefault();
        $('#files .speedbar-selected-face').removeClass('speedbar-selected-face');
        $(this).addClass('speedbar-selected-face');
        return loadFile($(this).attr('href').substring(1));
      });
      d = $('#files a.speedbar-directory-face, \
#files a.speedbar-button-face');
      return d.click(function(event) {
        var button, child, dir;
        event.preventDefault();
        dir = $(this).attr('href').substring(1);
        button = $("#files .speedbar-button-face[href='#" + (dir) + "']");
        child = $("#files div[dir = '" + (dir) + "']");
        if (button.text() === '<+>') {
          child.show();
          return button.text('<->');
        } else {
          child.hide();
          return button.text('<+>');
        }
      });
    };
    loadFile = function(file) {
      var loc;
      file = _.reduce(file.split('/'), files, function(fs, f) {
        return fs[f];
      });
      if (file.file) {
        $('#current-buffer').load("/files/" + (file.file));
      }
      if (file.js) {
        loc = file.js.split('#');
        return loc.length === 1 ? $('head').append(" \
<script type='text/javascript' src='/files/" + (loc[0]) + "'/>") : $('head').append(" \
<script type='text/javascript' lang='javascript'> \
require(['" + (loc[0]) + "'], function(" + (loc[0]) + "){ \
" + (loc[0]) + "." + (loc[1]) + "(); \
}); \
</script> \
");
      }
    };
    emacs.selectRandomTheme = function() {
      var name, names, rand;
      names = $("#themes .theme:visible a");
      rand = Math.floor(Math.random() * names.length);
      name = $(names[rand]);
      name.click();
      return name.focus();
    };
    buildFileList = function(level, files, into, parent) {
      parent = parent || "";
      return _.each(files, function(value, key) {
        var face, subdir;
        if (_.isString(value.file) || _.isString(value.js)) {
          face = key[0] === '*' ? 'tag' : 'file';
          return into.append(" \
<span style='padding-left:" + (level) + "em'></span> \
<a href='#" + (parent) + (key) + "' title='" + (value.title) + "' \
parent='" + (parent) + "' class='speedbar-" + (face) + "-face'>" + (key) + "</a> \
<br/> \
");
        } else {
          into.append(" \
<div> \
<span style='padding-left:" + (level) + "em'></span> \
<a href='#" + (parent) + (key) + "' class='speedbar-button-face'>&lt;+&gt;</a> \
<a href='#" + (parent) + (key) + "' class='speedbar-directory-face'>" + (key) + "</a> \
<div dir='" + (parent) + (key) + "' style='display:none'></div> \
</div> \
");
          subdir = $("#files div[dir='" + (parent) + (key) + "']");
          return buildFileList(level + 1, value, subdir, key + "/");
        }
      });
    };
    showThemeList = function(name) {
      var coll;
      coll = collection(name);
      displayThemeList(coll);
      $('span.theme-coll').text(name);
      return $('span.theme-coll-desc').text(coll[""] || "");
    };
    displayThemeList = function(themes) {
      var template;
      $('#themes .list').html($('#themes .resets').html());
      template = _.template(" \
<div class='theme'> \
<div class='name'> \
<a class='default bold' href='#<%=name%>'><%=name.replace(/^color-theme-/, '')%></a> \
</div> \
<div class='desc'> \
<%=desc[0]%> \
<div> \
<%=desc.slice(1).join('\n') %> \
</div> \
</div> \
</div> \
");
      _.each(themes, function(meta, name) {
        var html;
        if (name === "") {
          return null;
        }
        meta.name = name;
        html = template(meta);
        return $('#themes .list').append(html);
      });
      return setupThemeSearch();
    };
    setInitialTheme = function() {
      var theme;
      if (/#http/.test(location.hash)) {
        theme = downloadRemoteTheme(location.hash.substring(1));
      } else if (/#\d+/.test(location.hash)) {
        theme = downloadGistTheme(location.hash.substring(1));
      } else if (/#/.test(location.hash)) {
        theme = downloadLocalTheme(location.hash.substring(1));
      } else {
        theme = downloadLocalTheme(metaContent('theme-default'));
      }
      return installTheme(theme, true);
    };
    installTheme = function(meta, clear) {
      var base, css, faceNames, parent, theme;
      base = meta.mode === 'dark' ? base_dark : base_light;
      if (!(meta.css)) {
        if (meta.less) {
          meta.css = download(meta.less);
        } else {
          meta.css = lezz(meta.model);
        }
      }
      parent = {};
      if (!clear && current_theme) {
        parent = current_theme;
      }
      theme = $.extend(true, {}, parent, meta);
      if (clear) {
        $('style[emacs]').remove();
      }
      css = [("/*** LESS css for " + (theme.name) + " (" + (theme.mode) + ") ***/"), ("/*** Generated on " + (new Date()) + " from " + (window.location) + " ***/")];
      if (clear) {
        css.push("/*** ALWAYS ***/", always, "/*** ALWAYS:END ***/");
        css.push("/*** BASE ***/", base, "/*** BASE:END ***/");
      }
      css.push("/*** THEME " + (theme.name) + " ***/", meta.css, "/*** THEME:END **/");
      css = css.join("\n");
      $('<style>', {
        type: 'text/less',
        emacs: theme.name
      }).html(css).appendTo('head');
      try {
        less.refresh();
      } catch (e) {
        console.error('Error loading theme', e);
        throw e;
      }
      current_theme = theme;
      $('.theme-name').text(theme.name);
      $('.theme-name').val(theme.name);
      faceNames = $('#faceNames');
      _.each(_.keys(theme.model.faces).sort(), function(name) {
        return faceNames.append("<option class='" + (name) + "'>" + (name) + "</option>");
      });
      customizeFace('default');
      $('input.theme-name').trigger('themeChanged');
      return $('input.theme-name').trigger('themeLoaded');
    };
    customizeFace = function(name) {
      var _b, _c, bg, box_style, box_width, cls, colored, def, face, fg, match, sample;
      if (!(name)) {
        return null;
      }
      $('#faceNames').val(name);
      match = name.match(/font-lock-(.*)-face/);
      cls = match ? match[1] : name;
      sample = $('#faceSample');
      sample.attr('class', '').addClass(cls).text(name);
      fg = sample.css('color');
      bg = sample.css('background-color');
      def = $('<span class="default">');
      if (bg === 'transparent') {
        bg = def.css('background-color');
      }
      setPickColor('foreground', colors.cssRgbToHex(fg));
      setPickColor('background', colors.cssRgbToHex(bg));
      face = current_theme.model.faces[name] || {};
      $('.faceProps [name="family"]').val(face['family']);
      $('.faceProps [name="foundry"]').val(face['foundry']);
      $('.faceProps [name="width"]').val(face['width']);
      $('.faceProps [name="height"]').val(face['height']);
      $('.faceProps [name="slant"]').val(face['slant']);
      colored = function(selName) {
        var ary, pik, sel, val;
        ary = selName.split(':');
        val = face[ary[0]];
        if (ary.length > 1 && (typeof val !== "undefined" && val !== null)) {
          val = val[ary[1]];
        }
        sel = $(".faceProps select[name='" + (selName) + "']");
        pik = $(".faceProps .pickcolor[name='" + (selName) + "']");
        pik.attr('style', '');
        if (val === true || val === 'true') {
          return sel.val('on');
        } else if (val === false || !(typeof val !== "undefined" && val !== null) || val === 'false') {
          return sel.val('off');
        } else {
          sel.val('colored');
          return pik.css('background-color', val);
        }
      };
      colored('underline');
      colored('overline');
      colored('strike-through');
      box_style = ({
        "released-button": "raised",
        "pressed-button": "sunken",
        "null": "none",
        "undefined": "none",
        "false": "none",
        "": "none"
      })[("" + (function() {
        if (typeof (_b = face.box) !== "undefined" && _b !== null) {
          return face.box.style;
        }
      })())];
      $('.faceProps [name="box:style"]').val(box_style);
      if (typeof (_c = face.box) !== "undefined" && _c !== null) {
        box_width = face.box['line-width'];
      }
      $('.faceProps [name="box:line-width"]').val(box_width);
      return colored('box:color');
    };
    setFaceAttribute = function(name, value, faceName) {
      var css, face, set;
      if (!(current_theme)) {
        return null;
      }
      $('input.theme-name').trigger('themeChanged');
      faceName || (faceName = $('#faceNames').val());
      face = (current_theme.model.faces[faceName] || (current_theme.model.faces[faceName] = {}));
      if (name.match(/:/)) {
        set = function(v) {
          var here, match;
          match = name.split(':');
          here = (face[match[0]] || (face[match[0]] = {}));
          return (here[match[1]] = v);
        };
      } else {
        set = function(v) {
          return (face[name] = v);
        };
      }
      set(value);
      css = lezz.face(faceName, name, value);
      emacs = ("" + (faceName) + ":" + (name));
      $("head style[emacs='" + (emacs) + "']").remove();
      return $('head').append(" \
<style emacs='" + (emacs) + "' type='text/css'> \
" + (css) + " \
</style> \
");
    };
    setPickColor = function(name, color, value) {
      var pkr, target;
      if (!(typeof color !== "undefined" && color !== null)) {
        return null;
      }
      pkr = $(".faceProps .pickcolor[name='" + (name) + "']");
      pkr.css('background-color', color);
      pkr.ColorPickerSetColor(color);
      target = $(pkr.attr('target'));
      return target.is('select, input') ? target.val(value || color) : target.text(value || color);
    };
    setFaceColor = function(fg, color, updatePicker) {
      var attr, css, faceName, match, selector;
      if (!(current_theme)) {
        return null;
      }
      $('input.theme-name').trigger('themeChanged');
      attr = fg ? 'foreground' : 'background';
      faceName = $('#faceNames').val();
      current_theme.model.faces[faceName] || (current_theme.model.faces[faceName] = {});
      css = fg ? 'color' : 'background-color';
      current_theme.model.faces[faceName][attr] = color;
      emacs = ("" + (faceName) + ":" + (attr));
      selector = faceName;
      match = faceName.match(/font-lock-(.*)-face/);
      if (match) {
        selector = match[1];
      }
      $("head style[emacs='" + (emacs) + "']").remove();
      $('head').append(" \
<style emacs='" + (emacs) + "' type='text/css'> \
." + (selector) + " { " + (css) + ": " + (color) + "; } \
</style> \
");
      if (faceName === 'default') {
        return $('#faceNames').css(css, color);
      }
    };
    faceNameForElement = function(elem) {
      var classes, found;
      elem = $(elem);
      classes = (elem.attr('class') || '').split(/ +/);
      found = null;
      _.detect(classes.slice(0), function(cls) {
        if (current_theme.model.faces[cls]) {
          found = cls;
        }
        if (!(found)) {
          cls = ("font-lock-" + (cls) + "-face");
        }
        if (current_theme.model.faces[cls]) {
          found = cls;
        }
        return found;
      });
      if (found) {
        return found;
      } else if (elem.parent().length > 0) {
        return faceNameForElement(elem.parent());
      } else {
        return 'default';
      }
    };
    setCumulativeState = function(state) {
      cumulative = state;
      return cumulative ? $('span.cumulative-state').text('(nil)') : $('span.cumulative-state').text('(non-nil)');
    };
    emacs.init = function() {
      console.debug("Loading emacs");
      setCumulativeState(false);
      $('#faceNames').change(function() {
        return customizeFace($(this).val());
      });
      _.each($('.faceProps .pickcolor'), function(pick) {
        var name, selector, target;
        pick = $(pick);
        name = pick.attr('name');
        selector = pick.attr('target');
        target = $(selector);
        return pick.ColorPicker({
          onChange: function(hsb, hex, rgb) {
            pick.css('background-color', '#' + hex);
            return target.trigger('colorChange', '#' + hex);
          }
        });
      });
      $('.faceProps span[name="foreground"]').bind({
        colorChange: function(event, color) {
          $(this).text(color);
          return setFaceColor(true, color);
        }
      });
      $('.faceProps span[name="background"]').bind({
        colorChange: function(event, color) {
          $(this).text(color);
          return setFaceColor(false, color);
        }
      });
      $('.faceProps input[name]').change(function() {
        var name, val;
        name = $(this).attr('name');
        val = $(this).val() || '';
        if (val === '') {
          val = null;
        }
        return setFaceAttribute(name, val);
      });
      $('.faceProps select[name]').bind({
        colorChange: function() {
          $(this).val('colored');
          return $(this).trigger('change');
        }
      });
      $('.faceProps select[name]').change(function() {
        var name, picker, val;
        name = $(this).attr('name');
        val = $(this).val() || '';
        picker = $(".pickcolor[name='" + (name) + "']");
        if (val.match(/^(on|true|yes)$/i)) {
          val = true;
          picker.attr('style', '');
        } else if (val === '' || val.match(/^(off|false|no)$/i)) {
          val = false;
          picker.attr('style', '');
        } else if (val === 'colored') {
          val = colors.cssRgbToHex(picker.css('background-color'));
        }
        return setFaceAttribute(name, val);
      });
      $('button[href="#toggle-cumulative"]').click(function(event) {
        event.preventDefault();
        return setCumulativeState(!cumulative);
      });
      $('#themes a').live('click', function(event) {
        var clear, name, theme;
        event.preventDefault();
        $('#themes .secondary-selection').removeClass('secondary-selection');
        $(this).parent().parent().find('.desc').addClass('secondary-selection');
        clear = !cumulative;
        name = $(this).attr('href').substring(1);
        if (name === 'reset-light') {
          clear = true;
          name = metaContent('theme-light');
        } else if (name === 'reset-dark') {
          clear = true;
          name = metaContent('theme-dark');
        }
        theme = downloadLocalTheme(name);
        return installTheme(theme, clear);
      });
      $('.save').live('click', function(event) {
        var html;
        event.preventDefault();
        html = lisp(current_theme.model, {
          open: function(cls) {
            return cls === 'pre' ? "<pre id='dump-theme>'" : ("<span class='" + (cls) + "'>");
          },
          close: function(cls) {
            cls || (cls = "span");
            return "</" + (cls) + ">";
          },
          header: function(buffer, theme, htmlized) {
            buffer.push("<span class='comment'>");
            buffer.push(";; <span class='theme-name'>" + (current_theme.model.name) + "</span> generated on " + (new Date()) + "\n;;\n;; <span id='loading'>Creating gist.. please wait</span>\n;; <span id='reload'>\n;;   <span class='custom-invalid'>Warning: theme has changed</span>\n;;   <button class='save custom-button'>(revert-buffer)</button>\n;; </span>\n;; <span id='shares'>\n;;   <a id='gist-download-el' class='custom-button'></a> | <a id='gist-load' class='link'>Permalink</a> | <a id='gist-link' class='link' target='_blank'>Gist</a> | <a id='share-this' class='custom-button'></a>\n;; </span>");
            return buffer.push("</span>");
          }
        });
        $('#current-buffer').html(html);
        return _.defer(function() {
          return $.ajax({
            type: 'POST',
            url: '/gist',
            data: {
              name: current_theme.model.name,
              docs: current_theme.model.docs.join("\n"),
              lisp: lisp(current_theme.model),
              json: JSON.stringify(current_theme.model),
              less: lezz(current_theme.model)
            },
            success: function(gist) {
              var name, st;
              name = current_theme.model.name;
              $('#gist-link').attr('href', "http://gist.github.com/" + (gist)).text('Gist');
              $('#gist-download-el').attr('href', "/gist/" + (gist) + "/elisp/" + (name) + ".el").text('Download emacs-lisp');
              $('#gist-load').attr('href', "/#" + (gist)).text('Permalink');
              if (typeof stWidget !== "undefined" && stWidget !== null) {
                st = stWidget.addEntry({
                  service: 'sharethis',
                  element: $('#share-this')[0],
                  title: ("Emacs color-theme: " + (name)),
                  url: ("#" + (gist))
                }, {
                  button: true
                });
              }
              $('#share-this').text("Share " + (name));
              $('#shares').show();
              return $('#loading').hide();
            }
          });
        });
      });
      $('a.select-face-at-point').click(function(event) {
        event.preventDefault();
        return $('.frame').addClass('select_face_at_point');
      });
      $('.select_face_at_point *').live('hover', function(event) {
        event.preventDefault();
        return event.type === 'mouseover' ? $(this).addClass('face-at-point') : $(this).removeClass('face-at-point');
      });
      $('.select_face_at_point .face-at-point').live('click', function(event) {
        event.preventDefault();
        $('.frame').removeClass('select_face_at_point');
        $(this).removeClass('face-at-point');
        return customizeFace(faceNameForElement(this));
      });
      $('a.list-faces-display').click(function(event) {
        var sample;
        event.preventDefault();
        $('#current-buffer').html(" \
<h2>Faces display for " + (current_theme.model.name) + "</h2> \
<h5 class='widget-documentation'> \
To customize a face click on its name. \
</h5> \
");
        sample = "aeiou 01234567890 ABCDEF ~!@#$%^&*()[]{}=";
        _.each(_.keys(current_theme.model.faces).sort(), function(name) {
          var cls, match;
          match = name.match(/^font-lock-(.*)-face$/);
          if (match) {
            cls = match[1];
          } else {
            cls = name;
          }
          return $('#current-buffer').append(" \
<div class='listedface'> \
<div class='name'> \
<a class='button'>" + (name) + "</a> \
</div> \
<div class='desc'> \
<span class='" + (cls) + "'>" + (sample) + "</span> \
</div> \
</div> \
");
        });
        return $('.listedface a.button').click(function(event) {
          event.preventDefault();
          return customizeFace($(this).text());
        });
      });
      $('#themes select.theme-coll').change(function(event) {
        return showThemeList($(this).val());
      });
      $('input.theme-name').bind({
        keyup: function(event) {
          $('span.theme-name').text($(this).val());
          if (event.keyCode === 13) {
            $('#save').trigger('click');
            return $(this).trigger('themeLoaded');
          } else {
            return $(this).trigger('themeChanged');
          }
        },
        themeLoaded: function(event) {
          return $('span.modified').text('%%');
        },
        themeChanged: function(event) {
          $('span.modified').text('**');
          $('#current-buffer #shares').hide();
          return $('#current-buffer #reload').show();
        }
      });
      loadBase();
      return console.debug("Loaded emacs, current theme: ", current_theme);
    };
    return emacs;
  });
})();
