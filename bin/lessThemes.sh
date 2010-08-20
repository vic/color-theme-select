#!/usr/bin/env sh
#
#
#
to=${1:-less}
json=${2:-public/themes/json}
for i in $(find $json -type f -iname "*.json"); do
    o=$(echo $i | sed -r "s#json#${to}#g")
    sh bin/theme2${to}.sh $i $o
    echo $o
done
