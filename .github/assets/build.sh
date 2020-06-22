#!/bin/bash

set -euxo pipefail

build_type="$1"

pushd openthread

# Setup
./script/bootstrap
./bootstrap

# Build
if [[ "$build_type" == "posix" ]]
then
    make -f src/posix/Makefile-posix DAEMON=1
elif [[ "$build_type" == "nrf52840" ]]
then
    make -f examples/Makefile-nrf52840 USB=1
    for file in output/nrf52840/bin/*; do arm-none-eabi-objcopy -O ihex "$file" "$file.hex"; done
fi

popd
