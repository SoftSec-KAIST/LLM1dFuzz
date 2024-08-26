FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# (Temporary: replace URL for fast download during development)
RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -yy libc6-dev binutils libgcc-9-dev
RUN apt-get install -yy \
      wget apt-transport-https git unzip \
      build-essential libtool libtool-bin gdb \
      automake autoconf bison flex python python3 sudo vim

# Copied from OSS-FUZZ
ENV OUT=/out
ENV SRC=/src
ENV WORK=/work
ENV PATH="$PATH:/out"
RUN mkdir -p $OUT $SRC $WORK
ENV CMAKE_VERSION 3.21.1
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    chmod +x cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    ./cmake-$CMAKE_VERSION-Linux-x86_64.sh --skip-license --prefix="/usr/local" && \
    rm cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    rm -rf /usr/local/doc/cmake /usr/local/bin/cmake-gui
COPY docker-setup/checkout_build_install_llvm.sh /root/
RUN /root/checkout_build_install_llvm.sh
RUN rm /root/checkout_build_install_llvm.sh

# Install packages needed for fuzzers and benchmark
RUN apt-get update && \
    apt-get install -yy \
      # Several packages get uninstalled after LLVM setup.
      git build-essential bc \
      # For ParmeSan
      golang \
      # For Beacon
      libncurses5 \
      # For libming
      libfreetype6 libfreetype6-dev \
      # For libxml
      python-dev \
      # For libjpeg
      nasm \
      # For lrzip
      libbz2-dev liblzo2-dev \
      # For 32bit binaries
      gcc-multilib \
      # For libsndfile
      autogen \
      # For Lua
      libreadline-dev \
      # For poppler
      libfontconfig1-dev libjpeg-dev libopenjp2-7-dev libcairo2-dev \
      # For sqlite
      tcl

# Create a fuzzer directory and setup fuzzers there.
RUN mkdir /fuzzer
WORKDIR /fuzzer
COPY docker-setup/setup_AFLpp.sh /fuzzer/setup_AFLpp.sh
RUN ./setup_AFLpp.sh

# Setup SelectFuzz.
COPY docker-setup/pre-builts/SelectFuzz/SelectFuzz.tar.gz /fuzzer/SelectFuzz.tar.gz
COPY docker-setup/pre-builts/SelectFuzz/llvm4.tar.gz* /fuzzer/
COPY docker-setup/setup_SelectFuzz.sh /fuzzer/setup_SelectFuzz.sh
RUN ./setup_SelectFuzz.sh


# Create a benchmark directory and start working there.
RUN mkdir -p /benchmark/bin && \
    mkdir -p /benchmark/seed && \
    mkdir -p /benchmark/poc && \
    mkdir -p /benchmark/driver
COPY docker-setup/seed/empty /benchmark/seed/empty
WORKDIR /benchmark

# To use ASAN during the benchmark build, these option are needed.
ENV ASAN_OPTIONS=allocator_may_return_null=1,detect_leaks=0

# To use ASAN for php, below option is needed.
ENV USE_ZEND_ALLOC=0


# Build benchmark with AFLpp.
COPY docker-setup/benchmark-project /benchmark/project
COPY docker-setup/build_bench_common.sh /benchmark/build_bench_common.sh
COPY docker-setup/build_bench_ASAN.sh /benchmark/build_bench_ASAN.sh
RUN ./build_bench_ASAN.sh
COPY docker-setup/build_bench_AFLpp.sh /benchmark/build_bench_AFLpp.sh
RUN ./build_bench_AFLpp.sh

# Build benchmarks with SelectFuzz.
COPY docker-setup/build_bench_SelectFuzz.sh /benchmark/build_bench_SelectFuzz.sh
RUN ./build_bench_SelectFuzz.sh

# Copy line info for directed fuzzing.
COPY docker-setup/target/line /benchmark/target/line

# Copy scripts.
RUN mkdir /benchmark/scripts
COPY scripts/benchmark.py /benchmark/scripts
COPY scripts/common.py /benchmark/scripts
COPY scripts/triage.py /benchmark/scripts

# Copy script for updating seeds.
COPY docker-setup/update_seeds.sh /benchmark/

# Copy tool running scripts.
COPY docker-setup/tool-script /tool-script

# Reset the working directory to top-level directory.
WORKDIR /
