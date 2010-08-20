#!/usr/bin/env sh
FILE=${1}
OUT=${2:-"-"}
TEMP=$(tempfile)
cat <<EOF > $TEMP
console = {
   debug: function() { 
     java.lang.System.err.println(_(arguments).join(' ')); 
   },
   println: function() { 
     java.lang.System.out.println(_(arguments).join(' ')); 
   }
}

require({baseUrl: 'public/js'})
require(['colors', 'emacs/theme/less'], function(colors, theme2less){

var dbs = []
for(var i = 0; i < colors.colorDbs.length; i++){
  dbs.push('colors/'+colors.colorDbs[i]);
}

require(dbs, function(){

for(var i = 0; i < arguments.length; i++){
  colors.colorMaps[i] = arguments[i];
}

var data = new java.util.Scanner(new java.io.File("$FILE")).
               useDelimiter("\\Z").next();
var json;
json = eval("json = "+data);
var less = theme2less(json);
if("-" == "$OUT") {
  console.println(less);
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

});

});
EOF
js -f lib/require.js -f lib/require/rhino.js -f $TEMP
rm $TEMP
