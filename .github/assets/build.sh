#!/bin/bash

set -euxo pipefail

pushd openthread

# Setup
./script/bootstrap
./bootstrap

# Build
make -f src/posix/Makefile-posix DAEMON=1

popd
