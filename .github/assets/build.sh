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
    # We need to use the m4 from brew
    if [[ "$TARGET_OS" == macos* ]]
    then
        PATH=$(brew --prefix m4)/bin:$PATH
        export PATH
    fi
}

build_type="$1"
build "$build_type"
