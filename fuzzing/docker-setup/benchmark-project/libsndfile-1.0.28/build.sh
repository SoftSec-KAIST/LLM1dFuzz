#!/bin/bash

URL="https://github.com/libsndfile/libsndfile/archive/refs/tags/1.0.28.zip"

DIRNAME="libsndfile-1.0.28"
ARCHIVE=$DIRNAME".zip"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
cd $DIRNAME

autoreconf -f -i
./configure --disable-shared || exit 1
make -j || exit 1
cd ../
cp $DIRNAME/programs/sndfile-convert ./sndfile-convert || exit 1
