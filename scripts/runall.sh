#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Usage: runall.sh <benchmark-category> <machine-acronym>";
    echo "ex:    runall.sh linear-algebra/kernels nehalem-gcc";
    exit 1;
fi;

## Default value for the compilation line.
if [ -z "$COMPILER_COMMAND" ]; then
    COMPILER_COMMAND="gcc-4.5 -O3 -fopenmp -lm";
fi;

BENCHCAT="$1"
MACHINE="$2"
echo "Machine: $MACHINE";
echo "Benchmark category: $BENCHCAT";
rootdir=`pwd`;
cd "$BENCHCAT" &&
for i in `ls`; do
    if [ -d "$i" ] && [ -f "$i/$i.c" ]; then
	echo "Testing benchmark $i";
	rm -f $rootdir/data/$MACHINE-$i.dat
	if [ -f "$i/compiler.opts" ]; then
	    read comp_opts < $i/compiler.opts;
	    COMPILER_F_COMMAND="$COMPILER_COMMAND $comp_opts";
	else
	    COMPILER_F_COMMAND="$COMPILER_COMMAND";
	fi;
	for j in `find $i -name "*.c"`; do
	    echo "Testing $j";
	    $rootdir/scripts/compile.sh "$rootdir" "$COMPILER_F_COMMAND" "$j" "transfo" > /dev/null;
	    if [ $? -ne 0 ]; then
		echo "Problem when compiling $j";
	    else
		val=`./transfo`;
		if [ $? -ne 0 ]; then
		    echo "Problem when executing $j";
		else
		    cnt=0;
		    res="";
		    while [ $cnt -lt 5 ]; do
			val=`./transfo`;
			if [ $? -ne 0 ]; then
			    echo "Problem when executing $j";
			    res="-1";
			else
			    echo "execution time: $val";
			    res="$res $val";
			fi;
			cnt=$(($cnt + 1));
		    done;
		    output=`echo "$res" | sed -e "s/s//g"`;
		    echo "$j $output" >> $rootdir/data/$MACHINE-$i.dat
		fi;
	    fi;
	done;
    fi;
done;
cd ..;
