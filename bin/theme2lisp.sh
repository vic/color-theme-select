#!/usr/bin/env sh
FILE=${1}
OUT=${2:-"-"}
TEMP=$(tempfile)
cat <<EOF > $TEMP
var println = function() { java.lang.System.out.println(_(arguments).join(' ')); }
var debug = function() { java.lang.System.err.println(_(arguments).join(' ')); }
console = { debug: debug, log: debug };
var data = new java.util.Scanner(new java.io.File("$FILE")).
               useDelimiter("\\Z").next();
var json;
json = eval("json = "+data);
var less = exports.theme2lisp(json,false);
if("-" == "$OUT") {
  println(less);
} else {
  var file = new java.io.File("$OUT");
  file.getParentFile().mkdirs();
  var pw = new java.io.PrintWriter(
    new java.io.FileOutputStream(file)
  );
  pw.println(less);
  pw.flush();
  pw.close();
}
EOF
js -f underscore-min.js -f theme2lisp.js -f $TEMP
rm $TEMP
