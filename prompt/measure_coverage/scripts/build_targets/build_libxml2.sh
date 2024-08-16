#!/bin/bash

export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

rm -rf libxml2-2.9.4
wget https://github.com/GNOME/libxml2/archive/refs/tags/v2.9.4.zip -O libxml2-2.9.4.zip

unzip libxml2-2.9.4.zip

rm libxml2-2.9.4.zip

cd libxml2-2.9.4
./autogen.sh --disable-shared
make

#./configure CC="--coverage" 2>&1
#make 2>&1

