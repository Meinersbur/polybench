#!/bin/sh

echo "Expanding all .tar.gz archives:";
for i in `find . -name "*.tar.gz"`; do
    /bin/echo "$i";
    /bin/echo -n ".";
    dir=`dirname $i`;
    file=`basename $i`;
    cd "$dir" && tar xzf $file; cd -
done;
echo;
