#!/bin/bash

URL="https://gitlab.freedesktop.org/poppler/poppler/-/archive/poppler-0.73.0/poppler-poppler-0.73.0.zip"

DIRNAME="poppler-0.73.0"
ARCHIVE=$DIRNAME".zip"
LIBRARY="poppler"

wget $URL -O $ARCHIVE
rm -rf $DIRNAME
unzip $ARCHIVE || exit 1

# Stick to directory name conventions
mv $LIBRARY-$DIRNAME $DIRNAME
cd $DIRNAME

cmake -G"Unix Makefiles" || exit 1
make -j || exit 1
cd ../
cp $DIRNAME/utils/pdfimages ./pdfimages || exit 1

# Make sure that pdfimages can find the below file even after the build directory is removed.
# Fix a bug when AFLpp overwrites libpoppler, ASAN instrumented pdfimages doesn't work.
if [ ! -f /usr/local/lib ]; then
  mv $DIRNAME/libpoppler.so.84.0.0 /usr/local/lib
fi
ldconfig
