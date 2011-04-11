#!/bin/sh

if [ $# -ne 1 ]; then exit 1; fi

echo "Sync with repository $1";
if ! [ -d "$1" ]; then exit 2; fi

files=`find . | grep -v svn`;
for i in $files; do
    if ! [ -d "$i" ]; then
	newfile=`echo "$i" | sed -e "s/^\.//g"`;
	echo "file: $newfile";
	cp -f $i $1$newfile;
    fi;
done;
 
