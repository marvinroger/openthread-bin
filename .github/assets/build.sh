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
output_directory=""
if [[ "$OS" = ubuntu* ]]
then
    output_directory="x86_64-unknown-linux-gnu"
elif [[ "$OS" = macos* ]]
then
    output_directory="x86_64-apple-darwin"
else
    echo "Only ubuntu and macos are supported" && exit 1
fi
tar -zcvf ./build.tar.gz -C "./output/posix/${output_directory}" .
