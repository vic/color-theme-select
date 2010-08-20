# A wrapper around js console on firebug/chrome
# so that code doesn't fail on environments lacking console
# methods.

root = if window? then window else this
debug = if root.console?.debug? then (a...)->root.console.debug(a...) else ->
error = if root.console?.error? then (a...)->root.console.error(a...) else ->
log = if root.console?.log? then (a...)->root.console.log(a...) else ->

require.def 'console',
 debug: debug,
 error: error,
 log: log

