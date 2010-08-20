(function() {
  var requires;
  /*
  # Convert a JSON color-theme to emacs-lisp
  #
  */
  requires = ['emacs/theme/normalize', 'underscore-min', 'console'];
  require.def('emacs/theme/lisp', requires, function(normalize, _, console) {
    var box, identity, parseFaces, parseParams, parseTheme, parseValue, theme2lisp, valueMutator;
    _ = window._;
    theme2lisp = function(json, htmlized) {
      var htmlzied;
      json = normalize(json);
      if (!(typeof htmlized !== "undefined" && htmlized !== null)) {
        htmlized = {
          open: function() {
            return "";
          },
          close: function() {
            return "";
          }
        };
      } else if (htmlzied === true) {
        htmlzied = {
          open: function(cls) {
            return "<span class=\"" + (cls) + "\">";
          },
          close: function() {
            return "</span>";
          }
        };
      }
      return htmlized.open('pre') + parseTheme(json, htmlized) + htmlized.close('pre');
    };
    parseTheme = function(theme, htmlized) {
      var buffer;
      buffer = [];
      if (_.isFunction(htmlized.header)) {
        htmlized.header(buffer, theme, htmlized);
      } else {
        buffer.push(htmlized.open('comment'));
        buffer.push(";; -*- emacs-lisp -*-");
        buffer.push(";;");
        buffer.push(";;");
        buffer.push(";; name: " + (theme.name));
        buffer.push(";; date: " + (new Date()));
        buffer.push(";;");
        buffer.push(";;");
        buffer.push(";; To use this theme save this code into a");
        buffer.push(";; file named " + (theme.name) + ".el and place it");
        buffer.push(";; in a directory in your load-path");
        buffer.push(";;");
        buffer.push(";;    (require '" + (theme.name) + ")");
        buffer.push(";;    (" + (theme.name) + ")");
        buffer.push(";;");
        buffer.push(htmlized.close());
        buffer.push("");
      }
      buffer.push("(" + htmlized.open('keyword') + 'require' + htmlized.close() + " '" + htmlized.open('constant') + 'color-theme' + htmlized.close() + ")");
      buffer.push("");
      buffer.push("(" + htmlized.open('keyword') + 'defun' + htmlized.close() + ' ' + htmlized.open('function-name') + htmlized.open('theme-name') + theme.name + htmlized.close() + htmlized.close() + ' ()');
      buffer.push("  " + htmlized.open('doc') + '"' + _(theme.docs).join("  \n") + '"' + htmlized.close());
      buffer.push("  (interactive)");
      buffer.push("  (color-theme-install");
      buffer.push("    \'(" + htmlized.open('theme-name') + theme.name + htmlized.close());
      parseParams("      ", theme, theme.params, buffer, htmlized);
      parseParams("      ", theme, theme.args, buffer, htmlized);
      parseFaces("      ", theme, theme.faces, buffer, htmlized);
      buffer.push("     )");
      buffer.push("  )");
      buffer.push(")");
      buffer.push("");
      buffer.push("(" + htmlized.open('keyword') + 'provide' + htmlized.close() + " '" + htmlized.open('constant') + theme.name + htmlized.close() + ")");
      return _(buffer).join("\n");
    };
    parseFaces = function(space, theme, faces, buffer, htmlized) {
      var bfs;
      bfs = {};
      _.each(faces, function(attrs, name) {
        return _.each(attrs, function(value, attr) {
          var vls;
          vls = bfs[name] || [];
          bfs[name] = vls;
          vls.push(htmlized.open('builtin') + ':' + attr + htmlized.close());
          return vls.push(parseValue(value, attr, htmlized));
        });
      });
      return _.each(bfs, function(attrs, name) {
        return buffer.push(space + '(' + name + '  ((' + htmlized.open('keyword') + 't' + htmlized.close() + ' (' + _(attrs).join(' ') + ')))' + ')');
      });
    };
    parseParams = function(space, theme, params, buffer, htmlized) {
      buffer.push(space + '(');
      if (typeof params !== "undefined" && params !== null) {
        _.each(params, function(value, name) {
          return buffer.push(space + ' (' + name + ' . ' + parseValue(value, name, htmlized) + ')');
        });
      }
      return buffer.push(space + ')');
    };
    box = function(obj, htmlized) {
      var buffer;
      if (!(typeof obj !== "undefined" && obj !== null)) {
        return htmlized.open('keyword') + 'nil' + htmlized.close();
      }
      buffer = [];
      buffer.push('(');
      _.each(obj, function(value, key) {
        buffer.push(htmlized.open('builtin') + ':' + key + htmlized.close());
        return buffer.push(parseValue(value, key, htmlized));
      });
      buffer.push(')');
      return _(buffer).join(' ');
    };
    identity = function(i) {
      return i;
    };
    valueMutator = {
      "stiple": identity,
      "height": identity,
      "width": identity,
      "weight": identity,
      "inherit": identity,
      "style": identity,
      "line-width": identity,
      "slant": identity,
      "box": box
    };
    parseValue = function(value, key, htmlized) {
      var mutator;
      if (!(typeof value !== "undefined" && value !== null) || value === 'false' || value === false) {
        return htmlized.open('keyword') + 'nil' + htmlized.close();
      }
      if (value === 'true' || value === true) {
        return htmlized.open('keyword') + 't' + htmlized.close();
      }
      mutator = valueMutator[key];
      if (mutator) {
        return mutator(value, htmlized);
      }
      if (_.isString(value)) {
        return htmlized.open('string') + '"' + value + '"' + htmlized.close();
      }
      return value;
    };
    return theme2lisp;
  });
})();
