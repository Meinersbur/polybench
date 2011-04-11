#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: generate-refs.sh <benchmark name> [additional pocc flags]";
    exit 1;
fi

bench="$1";

pocc --verbose --pluto-tile --pluto-parallel  --pluto-prevector --pluto-fuse nofuse -o $bench.pluto-nofuse.c $bench.c $2
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pluto-nofuse.c";
fi;
pocc --verbose --pluto-tile --pluto-parallel  --pluto-prevector --pluto-fuse maxfuse -o $bench.pluto-maxfuse.c $bench.c $2
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pluto-maxfuse.c";
fi;
pocc --verbose --pluto-tile --pluto-parallel  --pluto-prevector --pluto-fuse smartfuse -o $bench.pluto-smartfuse.c $bench.c $2
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pluto-smartfuse.c";
fi;

pocc --verbose --pluto-tile --pluto-parallel  --pluto-fuse nofuse -o $bench.pocc-nofuse.c $bench.c $2 --vectorizer --pragmatizer
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pocc-nofuse.c";
fi;
pocc --verbose --pluto-tile --pluto-parallel  --pluto-fuse maxfuse -o $bench.pocc-maxfuse.c $bench.c $2  --vectorizer --pragmatizer
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pocc-maxfuse.c";
fi;
pocc --verbose --pluto-tile --pluto-parallel  --pluto-fuse smartfuse -o $bench.pocc-smartfuse.c $bench.c $2  --vectorizer --pragmatizer
if [ $? -ne 0 ]; then
    ERRORS="$ERRORS, bench.pocc-smartfuse.c";
fi;

if ! [ -z "$ERRORS" ]; then
    echo "Errors: $ERRORS";
    exit 1;
else
    echo "All versions successfully generated";
fi;
