(function() {
  var debug, error, gup, hasConsole, log, root;
  var __slice = Array.prototype.slice;
  gup = function(name) {
    var regex, regexS, results, tmpURL;
    regexS = "[\\?&]" + name + "=([^&#]*)";
    regex = new RegExp(regexS);
    tmpURL = window.location.href;
    results = regex.exec(tmpURL);
    return (results === null) ? null : results[1];
  };
  if (typeof window !== "undefined" && window !== null) {
    root = window;
  } else {
    root = this;
  }
  hasConsole = function(name) {
    var _a;
    return !!((!(typeof window !== "undefined" && window !== null) || ((typeof window !== "undefined" && window !== null) && gup('console'))) && (typeof (_a = root.console) !== "undefined" && _a !== null) && root.console[name]);
  };
  debug = hasConsole('debug') ? function() {
    var a;
    a = __slice.call(arguments, 0);
    return root.console.debug.apply(root.console, a);
  } : function() {};
  error = hasConsole('error') ? function() {
    var a;
    a = __slice.call(arguments, 0);
    return root.console.error.apply(root.console, a);
  } : function() {};
  log = hasConsole('log') ? function() {
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
