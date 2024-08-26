#!/bin/bash

FUZZER_NAME='SelectFuzz'
. $(dirname $0)/common-setup.sh

# Set exploitation time same as the provided docker image (45m)
timeout $4 /fuzzer/SelectFuzz/afl-fuzz \
  $DICT_OPT -m none -d  -z exp -c 45m -i seed/$5 -o output -- ./$1 $2


. $(dirname $0)/common-postproc.sh
