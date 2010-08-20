(function() {
  var requires;
  requires = ['emacs', 'console'];
  require.def('emacs/select_random', requires, function(emacs, console) {
    var $, JSON, _, _a;
    _a = [window._, window.$, window.JSON];
    _ = _a[0];
    $ = _a[1];
    JSON = _a[2];
    return console.debug('EMACS: ', emacs);
  });
})();
