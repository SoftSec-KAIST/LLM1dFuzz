#!/bin/bash

# We could not build SelectFuzz in our environment.
# Therefore, we clone the 6da35e0db9de6843db32c8ee69b41147e46c1795 version of SelectFuzz,
# which is the latest commit that we could find, then built it in the official docker image.
# Then, the prebuilt SelectFuzz is copied to docker by the Dockerfile.

# unzip SelectFuzz
cd /fuzzer
tar -zxf /fuzzer/SelectFuzz.tar.gz
rm /fuzzer/SelectFuzz.tar.gz

# Patch SelectFuzz to point to the right directory
file_path="/fuzzer/SelectFuzz/scripts/genDistance.sh"
sed -i '68s|opt -load /selectfuzz|opt -load /fuzzer/SelectFuzz|' $file_path
sed -i '96s|opt -load /selectfuzz|opt -load /fuzzer/SelectFuzz|' $file_path

# Install dependencies
apt-get -y install pip
pip3 install --upgrade pip
pip3 install networkx pydot pydotplus

# llvm-4 from the official Beacon docker image since building llvm 4 in our environment was not trivial.

# unzip llvm-4
# directory /fuzzer/SelectFuzz is made by upper code.
cat /fuzzer/llvm4.tar.gz* > /fuzzer/llvm4.tar.gz
tar -zxf /fuzzer/llvm4.tar.gz
cp -r /fuzzer/llvm4 /fuzzer/SelectFuzz
rm -rf /fuzzer/llvm4
rm /fuzzer/llvm4.tar.gz*
