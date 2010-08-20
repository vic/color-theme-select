(function() {
  var self;
  self = {
    cssRgbToHex: function(str) {
      var ary, hex;
      if (!(typeof str !== "undefined" && str !== null)) {
        return str;
      }
      ary = str.match(/\d+/g);
      if (ary === null) {
        return str;
      }
      hex = _.map(ary, function(c) {
        c = parseInt(c).toString(16);
        return c.length === 1 ? ("0" + (c)) : c;
      });
      return '#' + hex.join('');
    },
    rgbiToHex: function(rgbi) {
      var ary, hex;
      ary = rgbi.replace(/rgbi:/, '').split('/');
      hex = _.map(ary, function(c) {
        c = parseInt(c).toString(16);
        return c.length === 1 ? ("0" + (c)) : c;
      });
      return '#' + hex.join('');
    },
    inverseHex: function(str) {
      var ary, hex;
      ary = str.match(/[0-9A-F]{2}/gi);
      if (ary === null) {
        return str;
      }
      hex = _.map(ary, function(c) {
        c = (255 - parseInt(c, 16)).toString(16);
        return c.length === 1 ? ("0" + (c)) : c;
      });
      return '#' + hex.join('');
    },
    hexByNameInObject: function(name, colors) {
      if (!(typeof name !== "undefined" && name !== null) || name === '') {
        return null;
      }
      if (name.substring(0, 1) === '#') {
        return name;
      }
      name = name.replace(/ +/, '').toLowerCase();
      return colors[name] || colors[name.replace(/gray/g, 'grey')];
    },
    colorDbs: ['X11', 'CNE', 'X11', 'WWW', 'Crayola', 'Mozilla', 'IE'],
    colorMaps: [],
    hexByName: function(name) {
      var hex, i, len, map;
      if (!(typeof name !== "undefined" && name !== null)) {
        return null;
      }
      name = name.replace(/[ <>{}[\]]+/g, '');
      if (name === '') {
        return null;
      }
      if (name.substring(0, 1) === '#') {
        return name;
      }
      if (/^[0-9A-F]{6}$/i.test(name)) {
        return ("#" + (name));
      }
      if (/^rgbi:[\d\.\/]+$/.test(name)) {
        return self.rgbiToHex(name);
      }
      i = 0;
      hex = null;
      len = self.colorMaps.length;
      while (!(typeof hex !== "undefined" && hex !== null) && i < len) {
        map = self.colorMaps[i];
        hex = self.hexByNameInObject(name, map);
        i += 1;
      }
      return hex;
    }
  };
  require.def('colors', self);
})();
