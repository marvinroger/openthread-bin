#!/bin/bash

set -euxo pipefail


build() {
    local type="$1"
    pushd openthread

    # Setup
    ./script/bootstrap
    apply_workaround
    ./bootstrap

    # Build
    if [[ "$type" == "posix" ]]
    then
        make -f src/posix/Makefile-posix DAEMON=1
    elif [[ "$type" == "nrf52840" ]]
    then
        make -f examples/Makefile-nrf52840 USB=1
        for file in output/nrf52840/bin/*; do arm-none-eabi-objcopy -O ihex "$file" "$file.hex"; done
    fi

    popd
}

apply_workaround() {
    # m4 seems to be missing in ./script/bootstrap
    if [[ "$TARGET_OS" == macos* ]]
    then
        brew install m4
    fi
}

build_type="$1"
build "$build_type"
