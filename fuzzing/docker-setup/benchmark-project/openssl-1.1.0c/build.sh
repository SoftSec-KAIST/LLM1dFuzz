#!/bin/bash

URL="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_0c.zip"

DIRNAME="openssl-1.1.0c"
ARCHIVE=$DIRNAME".zip"
LIBRARY="openssl"
CONFIG_OPTIONS="no-asm enable-seed enable-cms \
                no-idea no-md2 no-md4 no-mdc2 no-rc2 \
                no-rc4 no-rc5 no-zlib-dynamic no-shared"
DEFAULT_FLAGS="-g -fno-omit-frame-pointer -Wno-error"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
mv $LIBRARY-OpenSSL_1_1_0c $DIRNAME
cd $DIRNAME

# Fix compile error
# ref: https://derrylab.com/index.php/2022/08/01/problem-when-building-old-openssl-version-on-the-new-system/
sed -i "17s/use if \$\^O ne \"VMS\", 'File::Glob' => qw\/glob\//use if \$\^O ne \"VMS\", 'File::Glob' => qw\/:glob\//" Configure
sed -i "292s/use if \$\^O ne \"VMS\", 'File::Glob' => qw\/glob\//use if \$\^O ne \"VMS\", 'File::Glob' => qw\/:glob\//" test/build.info

# CLOSED: Need to figure out how we should handle openssl-ASAN.
# CFLAG env may not work for openssl config (while CC works).
# As such, openssl should be compiled in a different way for ASAN as below:
# ./config no-asm enable-seed enable-cms no-idea no-md2 no-md4 no-mdc2 no-rc2 no-rc4 no-rc5 no-zlib-dynamic no-shared -fsanitize=address || exit 1

# PATCH: Check if CFLAGS environment variable is set
# PATCH: Insert the CFLAGS in a more general way to handle SelectFuzz as lua.
if [ -n "$CFLAGS" ]; then
    ./config $CONFIG_OPTIONS -O0 $CFLAGS || exit 1
fi

# If compile error occurs, remove -j option for make
make -j || exit 1
cd ../
cp $DIRNAME/apps/openssl ./openssl || exit 1
