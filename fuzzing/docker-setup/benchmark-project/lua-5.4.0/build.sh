#!/bin/bash

URL="https://github.com/lua/lua/archive/refs/tags/v5.4.0.zip"

DIRNAME="lua-5.4.0"
ARCHIVE=$DIRNAME".zip"
LIBRARY="lua"
VERSION="5.4.0"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1

cd $DIRNAME

# We don't use gcc when compiling binaries. 
# So, use clang if CC not set, and use CC otherwise.
if [ -z "$CC" ]; then
    CC="clang"
fi
sed -i "60s|gcc|$CC|" makefile || exit 1

# If -fsanitize=address is set, add -fsanitize=address
# option to MYCFLAGS and MYLDFLAGS
# This is because CC and CFLAGS does not work for Lua.
# PATCH: Insert the CFLAGS in a more general way to handle SelectFuzz.
if [ -n "$CFLAGS" ]; then
    sed -i "49i TESTS= -O0 $CFLAGS" makefile || exit 1
fi

make -j || exit 1
cd ../
cp $DIRNAME/lua ./lua || exit 1
