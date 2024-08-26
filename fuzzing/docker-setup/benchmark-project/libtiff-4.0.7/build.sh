#!/bin/bash

URL="https://gitlab.com/libtiff/libtiff/-/archive/v4.0.7/libtiff-v4.0.7.zip"

DIRNAME="libtiff-4.0.7"
ARCHIVE=$DIRNAME".zip"
LIBRARY="libtiff"
VERSION="4.0.7"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1

# Stick to directory name conventions
mv $LIBRARY-v$VERSION $DIRNAME
cd $DIRNAME
./autogen.sh || exit 1
./configure --disable-shared || exit 1
make -j || exit 1
cd ../
cp $DIRNAME/tools/tiffcp ./tiffcp || exit 1
