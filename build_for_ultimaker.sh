#!/bin/bash
#
# Copyright (C) 2025 Ultimaker B.V.
#

set -euo pipefail

SRC_DIR="$(pwd)"
RELEASE_VERSION="${RELEASE_VERSION:-9999.99.99}"
DOCKER_WORK_DIR="/build"

run_in_docker() {
    docker run \
        --rm \
        --privileged \
        -u "$(id -u):$(id -g)" \
        -v "${SRC_DIR}:${DOCKER_WORK_DIR}" \
        -e "RELEASE_VERSION=${RELEASE_VERSION:-}" \
        -w "${DOCKER_WORK_DIR}" \
        "${DOCKER_IMAGE_NAME}" \
        "$@"
}

build_docker_image() {
    local ARCH=$1
    local DOCKERFILE="docker_env/Dockerfile.${ARCH}"
    local IMAGE_NAME="framebuffer-vncserver:${ARCH}"

    echo "Building Docker image for ${ARCH}..."
    docker buildx build \
        --platform "linux/${ARCH}" \
        --load \
        -f "${DOCKERFILE}" \
        -t "${IMAGE_NAME}" .

    DOCKER_IMAGE_NAME="${IMAGE_NAME}"
}

if ! command -V docker; then
    echo "Docker not found, docker-less builds are not supported."
    exit 1
fi

cleanup()
{
    rm -rf "${SRC_DIR}/_build_armhf"
    rm -rf "${SRC_DIR}/_build_arm64"
}

cleanup

for ARCH in armhf arm64; do
    build_docker_image "${ARCH}"
    run_in_docker "./build.sh" "${ARCH}"
done

exit 0
