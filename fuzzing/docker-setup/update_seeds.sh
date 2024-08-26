#!/bin/bash

# arg1 : Target project
# arg2~: Fuzzing targets
function wrapper_function() {

    for TARG in "${@:2}"; do
        cd /benchmark

        str_array=($TARG)
        BIN_NAME=${str_array[0]}

        for BUG_NAME in "${str_array[@]:1}"; do
            copy_seeds_overwrite $1 $BIN_NAME $BUG_NAME
        done
    done
}


function copy_seeds_overwrite() {
    TARG=$2-$3
    # If we have 'poc' or 'poc-<binname>' directory, copy it.
    if [[ -d project/$1/poc ]]; then
        cp -r project/$1/poc /benchmark/poc/$2 || exit 1
    fi
    if [[ -d project/$1/poc-$2 ]]; then
        cp -r project/$1/poc-$2 /benchmark/poc/$2 || exit 1
    fi
    # If we have 'seed' or 'seed-<binname>' directory, copy it.
    # NOTE: nothing to do here to separate the seed directory into minimal / llm-best / llm-worst.
    # copying the project/$1/seed directory would copy all the subdirs as well.
    if [[ -d project/$1/seed-$2-$3 ]]; then
        cp -r project/$1/seed-$2-$3 /benchmark/seed/$TARG || exit 1
    elif [[ -d project/$1/seed-$2 ]]; then
        cp -r project/$1/seed-$2 /benchmark/seed/$TARG || exit 1
    elif [[ -d project/$1/seed ]]; then
        cp -r project/$1/seed /benchmark/seed/$TARG || exit 1
    fi
    # If we have driver, copy it.
    if [[ -d project/$1/driver-$2-$3 ]]; then
        cp -r project/$1/driver-$2-$3 /benchmark/driver/$TARG || exit 1
    elif [[ -d project/$1/driver-$2 ]]; then
        cp -r project/$1/driver-$2 /benchmark/driver/$TARG || exit 1
    elif [[ -d project/$1/driver ]]; then
        cp -r project/$1/driver /benchmark/driver/$TARG || exit 1
    fi
}

# Remove current seeds
mv /benchmark/seed/empty /benchmark
rm -rf /benchmark/seed
mkdir -p /benchmark/seed
mv /benchmark/empty /benchmark/seed

wrapper_function "libming-4.7" "swftophp-4.7 2016-9827" &
wrapper_function "lrzip-ed51e14" "lrzip-ed51e14 2018-11496" &
wrapper_function "binutils-2.26" "cxxfilt 2016-4487" &
wrapper_function "binutils-2.28" \
    "objdump 2017-8397" \
    "objcopy 2017-8393" &
wrapper_function "binutils-2.27" "strip 2017-7303" &
wrapper_function "binutils-2.29" \
    "nm 2017-14940" \
    "readelf 2017-16828" &
wrapper_function "libxml2-2.9.4" "xmllint 2017-9047" &
wrapper_function "libjpeg-1.5.90" "cjpeg-1.5.90 2018-14498" &

wrapper_function "libsndfile-1.0.28" "sndfile-convert 2018-19758" &
wrapper_function "lua-5.4.0" "lua 2020-24370" &
wrapper_function "php-7.3.6" "php 2019-11041" &
wrapper_function "libtiff-4.0.7" "tiffcp 2016-10269" &
wrapper_function "libpng-1.6.35" "pngimage 2018-13785" &
wrapper_function "openssl-1.1.0c" "openssl 2017-3735" &
wrapper_function "poppler-0.73.0" "pdfimages 2019-7310" &

wait

wrapper_function "sqlite-3.30.1" "sqlite3 2019-19923"
