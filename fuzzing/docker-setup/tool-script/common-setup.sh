#!/bin/bash

if [ $# -ne 5 ] && [ $# -ne 6 ] && [ $# -ne 7 ]; then
    echo "Usage: $0 <target program> <cmdline> <source> <timeout> <seed_mode> <additional option>"
    exit 1
fi

# Prepare a fresh working directory.
rm -rf /box
mkdir /box
cd /box

# Prepare target program, seed, and dictionary.
cp /benchmark/bin/$FUZZER_NAME/$1 ./$1
if [ -d "/benchmark/seed/$1" ]; then
    cp -r /benchmark/seed/$1 ./seed
else
    mkdir seed
    cp /benchmark/seed/empty ./seed/
fi
if [ -f "/benchmark/dict/$1" ]; then
    cp /benchmark/dict/$1 ./dict
    DICT_OPT="-x dict"
fi
if [ -d "/benchmark/driver/$1" ]; then
    cp -r /benchmark/driver/$1 ./driver
fi

# TODO: Try removing these options later.
export AFL_NO_AFFINITY=1
export AFL_SKIP_CRASHES=1

# Remove ASAN_OPTIONS previously set for the build process. If the target binary
# is compiled with ASAN, AFL will automatically set this variable appropriately.
unset ASAN_OPTIONS
START_TIME=`date "+%s"`
