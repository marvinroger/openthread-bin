#!/bin/bash

set -euxo pipefail

# Determine how to build
build_type="host"
docker_image=""
output_directory=""
if [[ "$TARGET_OS" == macos* && "$TARGET_ARCH" == "aarch64" ]]
then
    echo "No op" && exit 0
elif [[ "$TARGET_OS" == macos* ]]
then
    output_directory="x86_64-apple-darwin"
elif [[ "$TARGET_OS" == ubuntu* && "$TARGET_ARCH" == "aarch64" ]]
then
    build_type="docker"
    docker_image="arm64v8/ubuntu:18.04"
    output_directory="aarch64-unknown-linux-gnu"
elif [[ "$TARGET_OS" == ubuntu* ]]
then
    output_directory="x86_64-unknown-linux-gnu"
fi

git clone https://github.com/openthread/openthread.git

if [[ "$build_type" == "host" ]]
then
    ./.github/assets/build.sh
else
    sudo apt update -y && sudo apt install -y qemu qemu-user-static
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run \
        --workdir /github/workspace \
        --rm \
        -v "${PWD}:/github/workspace" \
        -t "$docker_image" \
        /bin/bash -c ./.github/assets/build.sh
fi

# Compress
tar -zcvf ./build.tar.gz -C "./openthread/output/posix/${output_directory}" .
