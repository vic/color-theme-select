(function() {
  var requires;
  /*
  # Convert a JSON color-theme to LESS css
  */
  requires = ['emacs/theme/normalize', 'underscore-min', 'console', 'colors'];
  require.def('emacs/theme/less', requires, function(normalize, _, console, colors) {
    var boxStyle, buildLess, cssColor, cssFontFamily, cssFontSize, cssInherit, cssOverline, cssSet, cssStrike, cssUnderline, cssWarning, foo, parseTheme, parseThemeFaces, parseThemeParams, setThemeValue, setters, singleFace;
    _ = (typeof window !== "undefined" && window !== null) ? window._ : this._;
    buildLess = function(buffer, nulls) {
      var more;
      more = [];
      _.each(buffer, function(atts, selector) {
        more.push("" + (selector) + " {\n");
        _.each(atts, function(value, attr) {
          var comment;
          if (attr === 'null' || !(typeof attr !== "undefined" && attr !== null)) {
            more.push("  " + (value));
          } else {
            comment = "";
            if (!(typeof value !== "undefined" && value !== null)) {
              if (!(nulls)) {
                comment = "//";
              }
            }
            more.push("  " + (comment) + (attr) + ": " + (value));
          }
          return more.push(";\n");
        });
        return more.push("}\n");
      });
      return _(more).join("");
    };
    singleFace = function(name, attr, value, nulls) {
      var buffer, key;
      buffer = {};
      key = name + ':' + attr;
      setThemeValue(key, value, buffer);
      return buildLess(buffer, nulls);
    };
    parseTheme = function(theme, nulls) {
      var _a, _b, _c, buffer;
      theme = normalize(theme);
      buffer = {};
      if (typeof (_a = theme.params) !== "undefined" && _a !== null) {
        parseThemeParams(theme.params, buffer);
      }
      if (typeof (_b = theme.args) !== "undefined" && _b !== null) {
        parseThemeParams(theme.args, buffer);
      }
      if (typeof (_c = theme.faces) !== "undefined" && _c !== null) {
        parseThemeFaces(theme.faces, buffer);
      }
      return buildLess(buffer, nulls);
    };
    parseThemeFaces = function(faces, buffer) {
      return _.each(faces, function(attrs, name) {
        return _.each(attrs, function(value, attr) {
          return (typeof value !== "undefined" && value !== null) && typeof (value) === 'object' ? _.each(value, function(val, nam) {
            var k;
            k = ("" + (name) + ":" + (attr) + ":" + (nam));
            return setThemeValue(k, val, buffer);
          }) : setThemeValue(name + ':' + attr, value, buffer);
        });
      });
    };
    parseThemeParams = function(params, buffer) {
      return _.each(params, function(value, key) {
        return (typeof value !== "undefined" && value !== null) && typeof (value) === 'object' ? _.each(value, function(val, name) {
          var k;
          k = key + ':' + name;
          return setThemeValue(k, value, buffer);
        }) : setThemeValue(key, value, buffer);
      });
    };
    setThemeValue = function(key, value, buffer) {
      return _(_.keys(setters)).detect(function(pattern) {
        var match, setter;
        if (match = key.match(new RegExp(pattern))) {
          setter = setters[pattern](match);
          setter.apply(this, [value, buffer]);
        }
        return match;
      });
    };
    boxStyle = function(value) {
      return ({
        "raised": "outset",
        "sunken": "inset",
        "released-button": "outset",
        "pressed-button": "inset",
        "none": "none",
        "nil": "none"
      })[value];
    };
    cssWarning = function(match) {
      return function(value, buffer) {
        if (!(typeof value !== "undefined" && value !== null) || value === 'nil') {
          return null;
        }
        cssSet("." + (match[1]), "foreground-color", cssColor)(value, buffer);
        return cssSet(".inspecting", "border-color", cssColor)(value, buffer);
      };
    };
    cssUnderline = function(match) {
      return function(value, buffer) {
        if (value === true || value === 'true' || value === 't') {
          cssSet("." + (match[1]), "border-bottom-style")("solid", buffer);
          return cssSet("." + (match[1]), "border-bottom-width")("thin", buffer);
        } else if (!(typeof value !== "undefined" && value !== null) || value === false || value === 'false' || value === 'nil') {
          return cssSet("." + (match[1]), "border-bottom-width")("0px", buffer);
        } else if (_.isString(value)) {
          cssSet("." + (match[1]), "border-bottom-color", cssColor)(value, buffer);
          cssSet("." + (match[1]), "border-bottom-style")("solid", buffer);
          return cssSet("." + (match[1]), "border-bottom-width")("thin", buffer);
        }
      };
    };
    cssOverline = function(match) {
      return function(value, buffer) {
        if (value === true || value === 'true' || value === 't') {
          cssSet("." + (match[1]), "border-top-style")("solid", buffer);
          return cssSet("." + (match[1]), "border-top-width")("thin", buffer);
        } else if (!(typeof value !== "undefined" && value !== null) || value === false || value === 'false' || value === 'nil') {
          return cssSet("." + (match[1]), "border-top-width")("0px", buffer);
        } else if (_.isString(value)) {
          cssSet("." + (match[1]), "border-top-color", cssColor)(value, buffer);
          cssSet("." + (match[1]), "border-top-style")("solid", buffer);
          return cssSet("." + (match[1]), "border-top-width")("thin", buffer);
        }
      };
    };
    cssStrike = function(match) {
      return function(value, buffer) {
        if (value === true || value === 'true' || value === 't') {
          return cssSet("." + (match[1]), "text-decoration")("line-through", buffer);
        } else if (!(typeof value !== "undefined" && value !== null) || value === false || value === 'false' || value === 'nil') {
          return cssSet("." + (match[1]), "text-decoration")("none", buffer);
        } else if (_.isString(value)) {
          cssSet("." + (match[1]), "text-decoration")("line-through", buffer);
          return cssSet("." + (match[1]), "//line-through-color", cssColor)(value, buffer);
        }
      };
    };
    cssFontSize = function(value) {
      return value;
    };
    cssFontFamily = function(value) {
      return "\"" + (value) + "\"";
    };
    cssColor = function(value) {
      var hex;
      if (!(typeof value !== "undefined" && value !== null) || value === false || value === 'false' || value === 'nil') {
        return 'transparent';
      }
      hex = colors.hexByName(value);
      if (!(hex)) {
        console.debug("COLOR NOT FOUND", value);
      }
      return hex ? hex : value;
    };
    cssInherit = function(parent) {
      parent = _.isArray(parent) ? parent : [parent];
      parent.map(function(p) {
        var match;
        match = ("" + (p)).match(/^font-lock-(.*)-face$/);
        return match ? ("." + (match[1])) : ("." + (p));
      });
      return parent.join(";\n");
    };
    foo = function() {
      var _a, parents, vals;
      if (!(typeof parents !== "undefined" && parents !== null)) {
        return null;
      }
      if (!(typeof (_a = parents.quote) !== "undefined" && _a !== null)) {
        parents = parents.quote;
      }
      if (_.isArray(parents)) {
        parents = (parents[0] === 'quote') ? parents.slice(1) : parents;
      }
      if (_.isString(parents)) {
        parents = [parents];
      }
      if (_.isArray(parents)) {
        parents = _(_(parents).keys().concat(_(parents).values())).reject(function(v) {
          return (typeof v !== "undefined" && v !== null);
        });
      }
      vals = _(parents).map(function(parent) {
        var match;
        match = ("" + (parent)).match(new RegExp("font-lock-(.*)-face"));
        if (typeof match !== "undefined" && match !== null) {
          parent = match[1];
        }
        return "." + (parent);
      });
      return vals.join("; ");
    };
    cssSet = function(selector, style, conversion) {
      return function(value, buffer) {
        var atts;
        if (_.isFunction(conversion)) {
          value = conversion.apply(this, [value]);
        } else if (_.isString(conversion)) {
          if (value === true) {
            value = conversion;
          } else {
            value = null;
          }
        }
        atts = (buffer[selector] || (buffer[selector] = {}));
        return (atts[style] = value);
      };
    };
    setters = {
      "^background-color$": function(match) {
        return cssSet('.default', 'background-color', cssColor);
      },
      "^foreground-color$": function(match) {
        return cssSet('.default', 'color', cssColor);
      },
      "^font-lock-(warning)-face:foreground$": function(match) {
        return cssWarning(match);
      },
      "^font-lock-(.*)-face:background$": function(match) {
        return cssSet('.' + match[1], 'background-color', cssColor);
      },
      "^font-lock-(.*)-face:foreground$": function(match) {
        return cssSet('.' + match[1], 'color', cssColor);
      },
      "^font-lock-(.*)-face:family$": function(match) {
        return cssSet('.' + match[1], 'font-family', cssFontFamily);
      },
      "^font-lock-(.*)-face:foundry$": function(match) {
        return cssSet('.' + match[1], '//font-foundry');
      },
      "^font-lock-(.*)-face:width$": function(match) {
        return cssSet('.' + match[1], 'font-stretch');
      },
      "^font-lock-(.*)-face:height$": function(match) {
        return cssSet('.' + match[1], 'font-size', cssFontSize);
      },
      "^font-lock-(.*)-face:bold$": function(match) {
        return cssSet('.' + match[1], 'font-weight', 'bold');
      },
      "^font-lock-(.*)-face:italic$": function(match) {
        return cssSet('.' + match[1], 'font-style', 'italic');
      },
      "^font-lock-(.*)-face:underline$": function(match) {
        return cssUnderline(match);
      },
      "^font-lock-(.*)-face:overline$": function(match) {
        return cssOverline(match);
      },
      "^font-lock-(.*)-face:strike-through$": function(match) {
        return cssStrike(match);
      },
      "^font-lock-(.*)-face:slant$": function(match) {
        return cssSet('.' + match[1], 'font-style');
      },
      "^font-lock-(.*)-face:weight$": function(match) {
        return cssSet('.' + match[1], 'font-weight');
      },
      "^font-lock-(.*)-face:box:color$": function(match) {
        return cssSet('.' + match[1], 'border-color', cssColor);
      },
      "^font-lock-(.*)-face:box:style$": function(match) {
        return cssSet('.' + match[1], 'border-style', boxStyle);
      },
      "^font-lock-(.*)-face:box:line-width$": function(match) {
        return cssSet('.' + match[1], 'border-width');
      },
      "^font-lock-(.*)-face:inherit$": function(match) {
        return cssSet('.' + match[1], null, cssInherit);
      },
      "^(.*):background$": function(match) {
        return cssSet('.' + match[1], 'background-color', cssColor);
      },
      "^(.*):foreground$": function(match) {
        return cssSet('.' + match[1], 'color', cssColor);
      },
      "^(.*):family$": function(match) {
        return cssSet('.' + match[1], 'font-family', cssFontFamily);
      },
      "^(.*):foundry$": function(match) {
        return cssSet('.' + match[1], '//font-foundry');
      },
      "^(.*):width$": function(match) {
        return cssSet('.' + match[1], 'font-stretch');
      },
      "^(.*):height$": function(match) {
        return cssSet('.' + match[1], 'font-size', cssFontSize);
      },
      "^(.*):bold$": function(match) {
        return cssSet('.' + match[1], 'font-weight', 'bold');
      },
      "^(.*):italic$": function(match) {
        return cssSet('.' + match[1], 'font-style', 'italic');
      },
      "^(.*):underline$": function(match) {
        return cssUnderline(match);
      },
      "^(.*):overline$": function(match) {
        return cssOverline(match);
      },
      "^(.*):strike-through$": function(match) {
        return cssStrike(match);
      },
      "^(.*):slant$": function(match) {
        return cssSet('.' + match[1], 'font-style');
      },
      "^(.*):weight$": function(match) {
        return cssSet('.' + match[1], 'font-weight');
      },
      "^(.*):box:color$": function(match) {
        return cssSet('.' + match[1], 'border-color', cssColor);
      },
      "^(.*):box:style$": function(match) {
        return cssSet('.' + match[1], 'border-style', boxStyle);
      },
      "^(.*):box:line-width$": function(match) {
        return cssSet('.' + match[1], 'border-width');
      },
      "^(.*):inherit$": function(match) {
        return cssSet('.' + match[1], null, cssInherit);
      },
      "^region$": function(match) {
        return cssSet('.region', 'background-color', cssColor);
      },
      "^(.*)$": function(match) {
        return function(value, buffer) {
          return cssSet('unknown', "// " + (match[1]))(value, buffer);
        };
      }
    };
    parseTheme.face = singleFace;
    return parseTheme;
  });
})();
