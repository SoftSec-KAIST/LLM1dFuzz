#!/bin/bash

URL="https://github.com/glennrp/libpng/archive/refs/tags/v1.6.35beta01.zip"

DIRNAME="libpng-1.6.35"
ARCHIVE=$DIRNAME".zip"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1
rm $ARCHIVE || exit 1

# Stick to directory name conventions
mv libpng-1.6.35beta01 $DIRNAME
cd $DIRNAME

# Referred to the original CVE report in the sourceforge repository.
sed -i 's/return ((int)(crc != png_ptr->crc));/return (0);/g' pngrutil.c

# Without ASAN
export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"

autoreconf -f -i
./configure --disable-shared || exit 1

# https://sourceforge.net/p/libpng/bugs/278/ says to make all, but make is still ok.
make -j || exit 1
