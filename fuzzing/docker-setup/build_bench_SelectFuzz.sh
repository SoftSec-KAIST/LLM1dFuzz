#!/bin/bash

. $(dirname $0)/build_bench_common.sh

# arg1 : Target project
# arg2~: Fuzzing targets
function build_with_SelectFuzz() {
    for TARG in "${@:2}"; do
        str_array=($TARG)
        BIN_NAME=${str_array[0]}

        cd /benchmark
        CC="/fuzzer/SelectFuzz/afl-clang-fast"
        CXX="/fuzzer/SelectFuzz/afl-clang-fast++"
#        TMP_DIR=/benchmark/temp_$1
        TMP_DIR=/benchmark/temp_$1_$BIN_NAME # Avoiding potential conflict for binutils binaries.

        for BUG_NAME in "${str_array[@]:1}"; do
            ### Draw CFG and CG with BBtargets
            mkdir -p $TMP_DIR
            
            # cp /benchmark/target/stack-trace/$BIN_NAME/$BUG_NAME $TMP_DIR/BBtargets.txt
            cp /benchmark/target/line/$BIN_NAME/$BUG_NAME $TMP_DIR/real.txt

            ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt \
                        -outdir=$TMP_DIR -flto -fuse-ld=gold \
                        -Wl,-plugin-opt=save-temps"
            build_target $1 $CC $CXX "$ADDITIONAL"
            # find /benchmark/RUNDIR-$1 -name "config.cache" -exec rm -rf {} \;

            cat $TMP_DIR/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt \
            && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
            cat $TMP_DIR/BBcalls.txt | sort | uniq > $TMP_DIR/BBcalls2.txt \
            && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt

            ### Compute Distances based on the graphs
            cd /benchmark/RUNDIR-$1
            /fuzzer/SelectFuzz/scripts/genDistance.sh $PWD $TMP_DIR $BIN_NAME

            ### Build with distance info
            cd /benchmark
            rm -rf /benchmark/RUNDIR-$1
            build_target $1 $CC $CXX "-fsanitize=address -distance=$TMP_DIR/distance.cfg.txt"

            ### copy results
            copy_build_result $1 $BIN_NAME $BUG_NAME "SelectFuzz"
            rm -rf /benchmark/RUNDIR-$1

            ### Cleanup
            rm -rf $TMP_DIR
        done
    done
}

export PATH=/fuzzer/SelectFuzz/llvm4/bin:$PATH
export PATH=/fuzzer/SelectFuzz/llvm4/lib:$PATH
export AFLGO=/fuzzer/SelectFuzz

# Build with SelectFuzz (Commented out projects that fail to build)
mkdir -p /benchmark/bin/SelectFuzz
build_with_SelectFuzz "libming-4.7" "swftophp-4.7 2016-9827" &
build_with_SelectFuzz "lrzip-ed51e14" "lrzip-ed51e14 2018-11496" &
build_with_SelectFuzz "binutils-2.26" "cxxfilt 2016-4487" &
build_with_SelectFuzz "binutils-2.28" "objcopy 2017-8393" &
#build_with_SelectFuzz "binutils-2.29" "readelf 2017-16828" &
build_with_SelectFuzz "libxml2-2.9.4" "xmllint 2017-9047" &
build_with_SelectFuzz "libjpeg-1.5.90" "cjpeg-1.5.90 2018-14498" &

build_with_SelectFuzz "libsndfile-1.0.28" "sndfile-convert 2018-19758" &
build_with_SelectFuzz "lua-5.4.0" "lua 2020-24370" &
#build_with_SelectFuzz "php-7.3.6" "php 2019-11041" &
build_with_SelectFuzz "libtiff-4.0.7" "tiffcp 2016-10269" &
build_with_SelectFuzz "libpng-1.6.35" "pngimage 2018-13785" &
#build_with_SelectFuzz "openssl-1.1.0c" "openssl 2017-3735" &
build_with_SelectFuzz "poppler-0.73.0" "pdfimages 2019-7310" &

wait

build_with_SelectFuzz "sqlite-3.30.1" "sqlite3 2019-19923"
