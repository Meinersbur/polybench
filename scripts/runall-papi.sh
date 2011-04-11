#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: runall.sh <machine-acronym> [large]";
    echo "The 'large' option makes use of the compiler.opts file";
    exit 1;
fi;


## Hard-wire we use Papi:
BENCH_PAPI=y;
PAPILIBDIR=/usr/local/lib

if [ "$2" = "large" ]; then
    LARGE=large;
else
    LARGE="";
fi;



## GCC Versions.
GCC=gcc-4.5
VERSION_1="gcc45-O0";
COMPILER_CMD_1="$GCC -O0";

VERSION_2="gcc45-O2-novec";
COMPILER_CMD_2="$GCC -O2 -fno-tree-vectorize";

VERSION_3="gcc45-O3-novec";
COMPILER_CMD_3="$GCC -O3 -fno-tree-vectorize";

VERSION_4="gcc45-O3-vec";
COMPILER_CMD_4="$GCC -O3 -ftree-vectorize  -fomit-frame-pointer -m64 -ftree-vectorizer-verbose=3";

VERSION_5="gcc45-O3-vec-openmp";
COMPILER_CMD_5="$GCC -O3 -ftree-vectorize  -fomit-frame-pointer -m64 -fopenmp -ftree-vectorizer-verbose=3";

VERSION_5b="gcc45-O3-vec-openmp-autopar";
COMPILER_CMD_5b="$GCC -O3 -ftree-vectorize  -fomit-frame-pointer -m64 -fopenmp -ftree-vectorizer-verbose=3 -ftree-parallelize-loops=16";


## ICC Versions.
ICC=/opt/intel/Compiler/11.1/072/bin/intel64/icc
#ICC=icc
VERSION_6="icc11-O0";
COMPILER_CMD_6="$ICC -O0";

VERSION_7="icc11-O2-novec";
COMPILER_CMD_7="$ICC -O2 -no-vec";

VERSION_7="icc11-fast-novec";
COMPILER_CMD_7="$ICC -fast -no-vec";

VERSION_8="icc11-fast-vec";
COMPILER_CMD_8="$ICC -fast -vec -vec-report5 -fomit-frame-pointer -m64 ";

VERSION_9="icc11-fast-vec-openmp";
COMPILER_CMD_9="$ICC -fast -vec -vec-report5  -fomit-frame-pointer -m64 -openmp ";

VERSION_10="icc11-fast-vec-openmp-autopar";
#COMPILER_CMD_10="$ICC -fast -vec -vec-report5  -fomit-frame-pointer -m64 -openmp -parallel -opt-report -par-report3";
COMPILER_CMD_10="$ICC -fast -fomit-frame-pointer -m64 -openmp -parallel ";


dump_entry()
{
    outfile="$1";
    exectime="$2";
    counters="$3";
    file="$4";

    bits="";
    ## bit 1,2: ufactor
    ## 0, 0 => no ufactor
    ## 0, 1 => ufactor_4
    ## 1, 1 => ufactor_8
    case "$file" in
	*ufactor_4*)
	    bits="0 1";;
	*ufactor_8*)
	    bits="1 1";;
	*)
	    bits="0 0";;
    esac;

    ## bit 3,4,5: fuse
    ## 0, 0, 0 => no fuse arg
    ## 0, 0, 1 => fuse_maxfuse
    ## 0, 1, 1 => fuse_nofuse
    ## 1, 1, 1 => fuse_smartfuse
    case "$file" in
	*fuse_maxfuse*)
	    bits="$bits 0 0 1";;
	*fuse_nofuse*)
	    bits="$bits 0 1 1";;
	*fuse_smartfuse*)
	    bits="$bits 1 1 1";;
	*)
	    bits="$bits 0 0 0";;
    esac;

    ## bit 6,7,8,9,10,11,12,13: tile
    ## 0, 0, 0, 0, 0, 0, 0, 0=> tile was not used
    ## 0, 0, 0, 0, 0, 0, 0, 1=> tile-1x1x1
    ## 0, 0, 0, 0, 0, 0, 1, 1=> tile-1x1x32
    ## 0, 0, 0, 0, 0, 1, 1, 1=> tile-1x32x1
    ## 0, 0, 0, 0, 1, 1, 1, 1=> tile-1x32x32
    ## 0, 0, 0, 1, 1, 1, 1, 1=> tile-32x1x1
    ## 0, 0, 1, 1, 1, 1, 1, 1=> tile-32x1x32
    ## 0, 1, 1, 1, 1, 1, 1, 1=> tile-32x32x1
    ## 1, 1, 1, 1, 1, 1, 1, 1=> tile-32x32x32
    case "$file" in
	*tile-1x1x1*)
	    bits="$bits 0 0 0 0 0 0 0 1";; 
	*tile-1x1x32*)
	    bits="$bits 0 0 0 0 0 0 1 1";; 
	*tile-1x32x1*)
	    bits="$bits 0 0 0 0 0 1 1 1";; 
	*tile-1x32x32*)
	    bits="$bits 0 0 0 0 1 1 1 1";; 
	*tile-32x1x1*)
	    bits="$bits 0 0 0 1 1 1 1 1";; 
	*tile-32x1x32*)
	    bits="$bits 0 0 1 1 1 1 1 1";; 
	*tile-32x32x1*)
	    bits="$bits 0 1 1 1 1 1 1 1";; 
	*tile-32x32x32*)
	    bits="$bits 1 1 1 1 1 1 1 1";; 
	*)
	    bits="$bits 0 0 0 0 0 0 0 0";;
    esac;


    ## bit 14: unroll
    ## 0 => unroll was not used
    ## 1 => unroll
    case "$file" in
	*unroll*)
	    bits="$bits 1";; 
	*)
	    bits="$bits 0";; 
    esac;

    ## bit 15: parallel
    ## 0 => parallel was not used
    ## 1 => parallel
    case "$file" in
	*parallel*)
	    bits="$bits 1";; 
	*)
	    bits="$bits 0";; 
    esac;

    ## bit 16: prevector
    ## 0 => prevector was not used
    ## 1 => prevector
    case "$file" in
	*prevector*)
	    bits="$bits 1";; 
	*)
	    bits="$bits 0";; 
    esac;

    ## OR: no bits, for the original code
    case "$file" in
	*verbose*)
	    bits="$bits";; 
	*)
	    bits="--original-code--";; 
    esac;

    entry="$exectime $counters $bits";
    entry=`echo "$entry" | sed -e 's/ /, /g'`;
    echo "$entry" >> $outfile
}


execute_program_version()
{
    file="$1";
    datafilename="$2";
    version="$3";
    COMPILER_COMMAND="$4";
    filename="$5";
    benchdir="$6";
    echo "** $file $version:" > /dev/stderr;
    $COMPILER_COMMAND -DPOLYBENCH_TIME  -lm -I utilities utilities/instrument.c "$file" -o transfo > /dev/stderr;
#     scripts/compile.sh "$COMPILER_COMMAND -DPOLYBENCH_TIME" "$file" "transfo" > /dev/stderr;
    if [ $? -ne 0 ]; then
	echo "Problem when compiling $file";
    else
	cnt=3;
	baseval=12123;
	while [ $cnt -ne 0 ]; do
	    ## timeout at 180s.
	    timeout=180
	    val=`perl -e 'alarm shift @ARGV; exec @ARGV' $timeout "./transfo"`;
	    if [ $? -ne 0 ]; then
		echo "Problem when executing $file";
		break;
	    fi;
	    baseval=`echo "$val $baseval" | awk '{if ($1 < $2) print $1; else print $2}'`;
	    cnt="$(($cnt - 1))";
	done;
	if [ $cnt -eq 0 ]; then
	    echo "$file-$version: $baseval (s)";
#	    echo "$file-$version $baseval" >> data/$datafilename.dat
	    exectime="$baseval";
	fi;
    fi;

if ! [ -z "$BENCH_PAPI" ]; then
## PAPI Specifics
    $COMPILER_COMMAND -DPOLYBENCH_PAPI -lpapi  -lm -I utilities utilities/instrument.c $PAPILIBDIR/libpapi.a "$file" -o transfo > /dev/stderr;
    if [ $? -ne 0 ]; then
	echo "Problem when compiling $file";
    else
	cnt=1;
	baseval=0;
	while [ $cnt -ne 0 ]; do
	    ## timeout at 180s.
	    timeout=240
	    val=`perl -e 'alarm shift @ARGV; exec @ARGV' $timeout "./transfo"`;
	    if [ $? -ne 0 ]; then
		echo "Problem when executing $file";
		break;
	    fi;
	    baseval=`echo $val | tail -n 1`;
	    cnt="$(($cnt - 1))";
	done;
	if [ $cnt -eq 0 ]; then
	    echo "$file-$version: PAPI counters= $baseval";
#	    echo "$file-$version $baseval" >> data/$datafilename.dat
	    dump_entry "data/$datafilename.dat" "$exectime" "$baseval" "$file";

	    dump_entry "data/$datafilename-full.dat" "$exectime" "$baseval" "$file";

	    newfilename=`basename $file`;
	    grep "$filename-pocc-flags/$newfilename" "$benchdir/$filename.c-similar-versions" > temp.txt;
	    while read n; do
		filedup=`echo "$n" | cut -d ' ' -f 2`;
		dump_entry "data/$datafilename-full.dat" "$exectime" "$baseval" "$filedup";
	    done < temp.txt;
	    rm -f temp.txt;
	fi;
    fi;
else
    echo "$file-$version $baseval" >> data/$datafilename.dat

fi;
}

## Global variables.
export LD_LIBRARY_PATH="/opt/intel/Compiler/11.1/072/lib/intel64:$LD_LIBRARY_PATH"

echo "Machine: $1";
for i in `find .`; do
    filename="";
    if [ -d "$i" ]; then
	filename="`basename $i`";
    fi;
    if [ -d "$i" ] && [ -f "$i/$filename.c" ]; then
	echo "Testing benchmark $i";
	rm -f data/$1-$filename.dat;
	rm -f data/$1-$filename-full.dat;
	if [ -f "$i/compiler.opts" ] && [ "$LARGE" = "large" ]; then
	    read comp_opts < $i/compiler.opts;
	    COMPILER_F_COMMAND="$comp_opts";
	else
	    COMPILER_F_COMMAND="";
	fi;
	for j in `find $i -name "*.c"`; do
	    echo "Testing $j";
## Sequential versions.
#	    execute_program_version "$j" "$1-$filename" "$VERSION_1" "$COMPILER_CMD_1 $COMPILER_F_COMMAND" "$filename" "$i";
#	    execute_program_version "$j" "$1-$filename" "$VERSION_2" "$COMPILER_CMD_2 $COMPILER_F_COMMAND" "$filename" "$i";
#	    execute_program_version "$j" "$1-$filename" "$VERSION_3" "$COMPILER_CMD_3 $COMPILER_F_COMMAND" "$filename" "$i";
#	    execute_program_version "$j" "$1-$filename" "$VERSION_4" "$COMPILER_CMD_4 $COMPILER_F_COMMAND" "$filename" "$i";

#	    execute_program_version "$j" "$1-$filename" "$VERSION_6" "$COMPILER_CMD_6 $COMPILER_F_COMMAND" "$filename" "$i";
#	    execute_program_version "$j" "$1-$filename" "$VERSION_7" "$COMPILER_CMD_7 $COMPILER_F_COMMAND" "$filename" "$i";
#	    execute_program_version "$j" "$1-$filename" "$VERSION_8" "$COMPILER_CMD_8 $COMPILER_F_COMMAND" "$filename" "$i";

## Parallel versions.
	    export OMP_SCHEDULE=static
	    export OMP_DYNAMIC=FALSE
	    export GOMP_CPU_AFFINITY="0-15";
	    export KMP_SCHEDULE=static,balanced
	    export KMP_AFFINITY="proclist=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]"
	    for threads in 16; do
		export OMP_NUM_THREADS="$threads";
## GCC
#		execute_program_version "$j" "$1-$filename" "$VERSION_5-threads=$threads" "$COMPILER_CMD_5 $COMPILER_F_COMMAND" "$filename" "$i";
#		execute_program_version "$j" "$1-$filename" "$VERSION_5b-threads=$threads" "$COMPILER_CMD_5b $COMPILER_F_COMMAND" "$filename" "$i";

## ICC
		export KMP_NUM_THREADS="$threads";
#		execute_program_version "$j" "$1-$filename" "$VERSION_9-threads=$threads" "$COMPILER_CMD_9 $COMPILER_F_COMMAND" "$filename" "$i";
		execute_program_version "$j" "$1-$filename" "$VERSION_10-threads=$threads" "$COMPILER_CMD_10 $COMPILER_F_COMMAND" "$filename" "$i";
	    done;
	done;
    fi;
done;
