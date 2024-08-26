#!/bin/bash
git clone https://github.com/AFLplusplus/AFLplusplus.git AFLpp || exit 1
cd AFLpp && git checkout 4.07c || exit 1
make
