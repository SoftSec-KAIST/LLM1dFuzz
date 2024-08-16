#!/bin/bash

URL="https://github.com/lua/lua/archive/refs/tags/v5.4.0.zip"

DIRNAME="lua-5.4.0"
ARCHIVE=$DIRNAME".zip"
LIBRARY="lua"
VERSION="5.4.0"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE

cd $DIRNAME

# Lua uses gcc as default. But, imply it explicitly.
# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

# Below is because CC and CFLAGS does not work for Lua.
sed -i "49i TESTS= --coverage -fno-omit-frame-pointer -Wno-error" makefile || exit 1

make -j || exit 1
