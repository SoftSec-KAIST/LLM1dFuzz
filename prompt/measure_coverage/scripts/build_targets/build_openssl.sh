#!/bin/bash

URL="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_0c.zip"

DIRNAME="openssl-1.1.0c"
ARCHIVE=$DIRNAME".zip"
LIBRARY="openssl"
CONFIG_OPTIONS="no-asm enable-seed enable-cms \
                no-idea no-md2 no-md4 no-mdc2 no-rc2 \
                no-rc4 no-rc5 no-zlib-dynamic no-shared"
DEFAULT_FLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE
mv $LIBRARY-OpenSSL_1_1_0c $DIRNAME
cd $DIRNAME

# Fix compile error
# ref: https://derrylab.com/index.php/2022/08/01/problem-when-building-old-openssl-version-on-the-new-system/
sed -i "17s/use if \$\^O ne \"VMS\", 'File::Glob' => qw\/glob\//use if \$\^O ne \"VMS\", 'File::Glob' => qw\/:glob\//" Configure
sed -i "292s/use if \$\^O ne \"VMS\", 'File::Glob' => qw\/glob\//use if \$\^O ne \"VMS\", 'File::Glob' => qw\/:glob\//" test/build.info

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

# CFLAG env may not work for openssl config (while CC works).
./config $CONFIG_OPTIONS -O0 $DEFAULT_FLAGS || exit 1

# If compile error occurs, remove -j option for make
make -j || exit 1
