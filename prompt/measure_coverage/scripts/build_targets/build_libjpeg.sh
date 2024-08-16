#!/bin/bash

export CC="gcc"
export CXX="g++"
export CFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"
export CXXFLAGS="--coverage -fno-omit-frame-pointer -Wno-error"


wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/1.5.90.zip -O libjpeg-turbo-1.5.90.zip
rm -rf libjpeg-turbo-1.5.90
unzip libjpeg-turbo-1.5.90.zip

rm libjpeg-turbo-1.5.90.zip

cd libjpeg-turbo-1.5.90
cmake -G"Unix Makefiles"
make
