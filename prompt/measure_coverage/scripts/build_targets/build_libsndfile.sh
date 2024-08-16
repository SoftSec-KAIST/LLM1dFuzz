#!/bin/bash

URL="https://github.com/libsndfile/libsndfile/archive/refs/tags/1.0.28.zip"

DIRNAME="libsndfile-1.0.28"
ARCHIVE=$DIRNAME".zip"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE

cd $DIRNAME

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

autoreconf -f -i
./configure --disable-shared || exit 1
make -j || exit 1
