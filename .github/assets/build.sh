#!/bin/bash

set -euxo pipefail

git clone https://github.com/openthread/openthread.git
cd openthread

# Setup
./script/bootstrap
./bootstrap

# Build
make -f src/posix/Makefile-posix DAEMON=1
