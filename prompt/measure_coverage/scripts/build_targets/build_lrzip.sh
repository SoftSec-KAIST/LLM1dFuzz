#!/bin/bash

#sudo apt-get install libbz2-dev
#sudo apt-get install liblzo2-dev

rm -rf lrzip
git clone https://github.com/ckolivas/lrzip.git
cd lrzip
git reset --hard ed51e14

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

./autogen.sh

./configure

make
