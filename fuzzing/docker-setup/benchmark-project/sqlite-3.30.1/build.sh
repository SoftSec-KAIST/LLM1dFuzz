#!/bin/bash

URL="https://github.com/sqlite/sqlite/archive/refs/tags/version-3.30.1.zip"

DIRNAME="sqlite-3.30.1"
ARCHIVE=$DIRNAME".zip"
LIBRARY="sqlite"
VERSION="3.30.1"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1

# Stick to directory name conventions
mv $LIBRARY-version-$VERSION $DIRNAME
cd $DIRNAME

# sqlite complains about tcl PATH, but well compiles without setting PATH

./configure --disable-shared || exit 1
make -j || exit 1
cd ../
cp $DIRNAME/sqlite3 ./sqlite3 || exit 1
