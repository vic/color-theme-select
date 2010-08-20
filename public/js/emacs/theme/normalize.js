(function() {
  var requires;
  var __bind = function(func, context) {
    return function(){ return func.apply(context, arguments); };
  };
  /*
  # Normalize a JSON color-theme as returned by emacs' json-encode
  # to a more usable format.
  */
  requires = ['underscore-min', 'console'];
  require.def('emacs/theme/normalize', requires, function(_, console) {
    var normalize;
    _ = (typeof window !== "undefined" && window !== null) ? window._ : this._;
    normalize = __bind(function(json) {
      var _a, faces, theme;
      if (typeof (_a = json.params) !== "undefined" && _a !== null) {
        return json;
      }
      theme = {
        name: json.data[0],
        params: json.data[1],
        docs: json.docs,
        args: {},
        faces: {}
      };
      faces = [];
      if (!(_.isArray(json.data[2]))) {
        theme.args = json.data[2];
        faces = json.data.slice(3);
      } else {
        faces = json.data.slice(2);
      }
      _.each(faces, function(face) {
        var _b, _c, _d, _e, _f, _g, _h, a, ary, attrs, first, h, i, j, key, name, spec, value;
        name = face[0];
        spec = face[1]['true'];
        first = null;
        _b = spec;
        for (first in _b) {
          value = _b[first];
          value;
        }
        if (!(typeof first !== "undefined" && first !== null) || first === 'null') {
          return null;
        }
        ary = [first].concat(spec[first]);
        _c = []; _d = ary.length;
        for (i = 0; (0 <= _d ? i <= _d : i >= _d); i += 2) {
          _c.push((function() {
            key = ary[i];
            value = ary[i + 1];
            attrs = (theme.faces[name] || (theme.faces[name] = {}));
            if (_.isArray(value)) {
              attrs[key] = {};
              _e = []; _f = value.length;
              for (j = 0; (0 <= _f ? j <= _f : j >= _f); j += 2) {
                _e.push(attrs[key][value[j]] = value[j + 1]);
              }
              return _e;
            } else {
              return (typeof value !== "undefined" && value !== null) && (function() {
                if (typeof (value) === 'object' && _.keys(value).length === 1 && _.isArray(_.values(value)[0])) {
                  a = _.keys(value).concat(_.values(value));
                  h = {};
                  _g = a.length;
                  for (j = 0; (0 <= _g ? j <= _g : j >= _g); j += 2) {
                    if (typeof (_h = h[a[j + 1]]) !== "undefined" && _h !== null) {
                      h[a[j]] = h[a[j + 1]];
                    }
                  }
                  return (attrs[key] = h);
                } else if (typeof value !== "undefined" && value !== null) {
                  return (attrs[key] = value);
                }
              })();
            }
          })());
        }
        return _c;
      });
      return theme;
    }, this);
    return normalize;
  });
})();
