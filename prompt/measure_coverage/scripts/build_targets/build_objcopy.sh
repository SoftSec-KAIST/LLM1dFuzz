#!/bin/bash

wget http://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.gz -O binutils-2.28.tar.gz
rm -rf binutils-2.28
tar -xzf binutils-2.28.tar.gz
rm binutils-2.28.tar.gz
cd binutils-2.28

export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -DFORTIFY_SOURCE=2 -fstack-protector-all -fno-omit-frame-pointer -Wno-error"

export ASAN_OPTIONS=allocator_may_return_null=1
export ASAN_OPTIONS=detect_leaks=0

./configure --disable-shared --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-ld

make -j
