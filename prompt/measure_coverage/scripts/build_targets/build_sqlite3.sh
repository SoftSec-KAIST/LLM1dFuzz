#!/bin/bash

export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

URL="https://github.com/sqlite/sqlite/archive/refs/tags/version-3.30.1.zip"

DIRNAME="sqlite-3.30.1"
ARCHIVE=$DIRNAME".zip"
LIBRARY="sqlite"
VERSION="3.30.1"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE

# Stick to directory name conventions
mv $LIBRARY-version-$VERSION $DIRNAME
cd $DIRNAME

# sqlite complains about tcl PATH, but well compiles without setting PATH
./configure --disable-shared || exit 1
make -j || exit 1
