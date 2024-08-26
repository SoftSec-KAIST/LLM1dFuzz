#!/bin/bash

FUZZER_NAME='AFLpp'
. $(dirname $0)/common-setup.sh

timeout $4 /fuzzer/AFLpp/afl-fuzz \
  $DICT_OPT -m none -d -i seed/$5 -o output $6 -- ./$1 $2

. $(dirname $0)/common-postproc-AFLpp.sh
