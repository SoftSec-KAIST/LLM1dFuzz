#!/bin/bash

. $(dirname $0)/build_bench_common.sh

# arg1 : Target project
# arg2~: Fuzzing targets
function build_with_AFLpp() {
    CC="/fuzzer/AFLpp/afl-clang-lto"
    CXX="/fuzzer/AFLpp/afl-clang-lto++"

    for TARG in "${@:2}"; do
        cd /benchmark

        str_array=($TARG)
        BIN_NAME=${str_array[0]}
        if  [[ $BIN_NAME == "readelf" || $BIN_NAME == "binutils-2.31.1" ]]; then
            BIT_OPT="-m32"
        else
            BIT_OPT=""
        fi

        build_target $1 $CC $CXX "-fsanitize=address $BIT_OPT"

        for BUG_NAME in "${str_array[@]:1}"; do
            copy_build_result $1 $BIN_NAME $BUG_NAME "AFLpp"
        done
    done
    rm -rf RUNDIR-$1 || exit 1
}

# Build with AFLpp
mkdir -p /benchmark/bin/AFLpp
build_with_AFLpp "libming-4.7" "swftophp-4.7 2016-9827" &
build_with_AFLpp "lrzip-ed51e14" "lrzip-ed51e14 2018-11496" &
build_with_AFLpp "binutils-2.26" "cxxfilt 2016-4487" &
build_with_AFLpp "binutils-2.28" "objcopy 2017-8393" &
build_with_AFLpp "binutils-2.29" "readelf 2017-16828" &
build_with_AFLpp "libxml2-2.9.4" "xmllint 2017-9047" &
build_with_AFLpp "libjpeg-1.5.90" "cjpeg-1.5.90 2018-14498" &

build_with_AFLpp "libsndfile-1.0.28" "sndfile-convert 2018-19758" &
build_with_AFLpp "lua-5.4.0" "lua 2020-24370" &
build_with_AFLpp "php-7.3.6" "php 2019-11041" &
build_with_AFLpp "libtiff-4.0.7" "tiffcp 2016-10269" &
build_with_AFLpp "libpng-1.6.35" "pngimage 2018-13785" &
build_with_AFLpp "openssl-1.1.0c" "openssl 2017-3735" &
build_with_AFLpp "poppler-0.73.0" "pdfimages 2019-7310" &

wait

build_with_AFLpp "sqlite-3.30.1" "sqlite3 2019-19923"
