#!/bin/bash

rm -rf libming-0.4.7
git clone https://github.com/libming/libming.git libming-0.4.7
cd libming-0.4.7
git checkout ming-0_4_7
./autogen.sh

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

./configure --disable-shared --disable-freetype 

make

