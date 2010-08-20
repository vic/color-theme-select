(function() {
  var _a, _b, _c, debug, error, log, root;
  var __slice = Array.prototype.slice;
  root = (typeof window !== "undefined" && window !== null) ? window : this;
  debug = (typeof (_a = root.console == null ? undefined : root.console.debug) !== "undefined" && _a !== null) ? function() {
    var a;
    a = __slice.call(arguments, 0);
    return root.console.debug.apply(root.console, a);
  } : function() {};
  error = (typeof (_b = root.console == null ? undefined : root.console.error) !== "undefined" && _b !== null) ? function() {
    var a;
    a = __slice.call(arguments, 0);
    return root.console.error.apply(root.console, a);
  } : function() {};
  log = (typeof (_c = root.console == null ? undefined : root.console.log) !== "undefined" && _c !== null) ? function() {
    var a;
    a = __slice.call(arguments, 0);
    return root.console.log.apply(root.console, a);
  } : function() {};
  require.def('console', {
    debug: debug,
    error: error,
    log: log
  });
})();
