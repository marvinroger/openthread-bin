#!/bin/bash

set -euxo pipefail

# Determine how to build
build_type="posix"
env_type="host"
dockerfile_arch=""
output_directory=""
if [[ "$TARGET_OS" == macos* && "$TARGET_ARCH" != "x86_64" ]]
then
    echo "No op"
    echo "::set-output name=no_op::1"
    exit 0
elif [[ "$TARGET_OS" == macos* ]]
then
    output_directory="x86_64-apple-darwin"
elif [[ "$TARGET_OS" == ubuntu* && "$TARGET_ARCH" == "aarch64" ]]
then
    env_type="docker"
    dockerfile_arch="aarch64"
    output_directory="aarch64-unknown-linux-gnu"
elif [[ "$TARGET_OS" == ubuntu* && "$TARGET_ARCH" == "nrf52840" ]]
then
    build_type="nrf52840"
elif [[ "$TARGET_OS" == ubuntu* ]]
then
    output_directory="x86_64-unknown-linux-gnu"
fi

git clone -n https://github.com/openthread/openthread.git
pushd openthread
git checkout "${OPENTHREAD_SHA}"
popd

if [[ "$env_type" == "host" ]]
then
    ./.github/assets/build.sh "${build_type}"
else
    sudo apt update -y && sudo apt install -y qemu qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker build -t ot_environment -f "./.github/assets/Dockerfile.$dockerfile_arch" .
    docker run \
        --workdir /github/workspace \
        --rm \
        -v "${PWD}:/github/workspace" \
        -t ot_environment \
        /bin/bash -c './.github/assets/build.sh "$0"' "${build_type}"
fi

# Compress
tar -zcvf ./build.tar.gz -C "./openthread/output/${build_type}" .
