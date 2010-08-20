# A wrapper around js console on firebug/chrome
# so that code doesn't fail on environments lacking console
# methods.

gup = (name)->
 regexS = "[\\?&]"+name+"=([^&#]*)";
 regex = new RegExp ( regexS );
 tmpURL = window.location.href;
 results = regex.exec( tmpURL )
 if( results == null )
   null
 else
   results[1]

if window?
  root = window
else
  root = this

hasConsole = (name)->
  !!((!window? || (window? && gup('console'))) && root.console? && root.console[name])

debug = if hasConsole('debug') then (a...)->root.console.debug(a...) else ->
error = if hasConsole('error') then (a...)->root.console.error(a...) else ->
log = if hasConsole('log') then (a...)->root.console.log(a...) else ->

require.def 'console',
 debug: debug,
 error: error,
 log: log

