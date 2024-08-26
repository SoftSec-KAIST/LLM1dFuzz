#!/bin/bash

URL="https://github.com/php/php-src/archive/refs/tags/php-7.3.6.zip -O php-7.3.6.zip"

DIRNAME="php-7.3.6"
ARCHIVE=$DIRNAME".zip"
LIBRARY="php"
CONFIG_OPTIONS="--disable-all --enable-cli \
                --enable-exif --enable-debug \
                --disable-phar --without-pear \
                --disable-phpdbg --disable-cgi"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1

# Stick to directory name conventions
mv $LIBRARY-src-$DIRNAME $DIRNAME
cd $DIRNAME

# NOTE: USE_ZEND_ALLOC=0 is set in the Dockerfile

# NOTE: Some functions are explicitly set as used functions due to
# the LTO bug: ld.lld: error: undefined hidden symbol: XX
# (issue: https://github.com/AFLplusplus/AFLplusplus/issues/226)
# (fix: https://sourceforge.net/p/mingw-w64/mailman/mingw-w64-public/thread/778a777e-edff-35b6-a30c-85ccbf536ade%40126.com/)

# php-7.3.6/ext/standard/base64.c: 739, 761
sed -i "739i __attribute__((used))" ext/standard/base64.c # encode_default
sed -i "761i __attribute__((used))" ext/standard/base64.c # decode_ex_default
# php-7.3.6/ext/standard/string.c: 4087, 4246
sed -i "4087i __attribute__((used))" ext/standard/string.c # addslashes_default
sed -i "4246i __attribute__((used))" ext/standard/string.c # stripslashes_default

./buildconf --force
aclocal && libtoolize --force && autoreconf -fi

./configure $CONFIG_OPTIONS || exit 1
make -j || exit 1
cd ../
cp $DIRNAME/sapi/cli/php ./php || exit 1
