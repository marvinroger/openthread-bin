#!/bin/bash

set -euxo pipefail

git clone https://github.com/openthread/openthread.git
cd openthread

# Setup
./script/bootstrap
./bootstrap

# Build
make -f src/posix/Makefile-posix DAEMON=1

# Compress
tar -zcvf ./build.tar.gz -C ./output/posix/x86_64-unknown-linux-gnu .
