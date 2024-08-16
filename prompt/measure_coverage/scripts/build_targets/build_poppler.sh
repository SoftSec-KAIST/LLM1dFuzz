#!/bin/bash

URL="https://gitlab.freedesktop.org/poppler/poppler/-/archive/poppler-0.73.0/poppler-poppler-0.73.0.zip"

DIRNAME="poppler-0.73.0"
ARCHIVE=$DIRNAME".zip"
LIBRARY="poppler"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE

# Stick to directory name conventions
mv $LIBRARY-$DIRNAME $DIRNAME
cd $DIRNAME

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

cmake -G"Unix Makefiles" || exit 1
make -j || exit 1
