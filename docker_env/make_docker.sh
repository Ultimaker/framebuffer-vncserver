#!/bin/bash
#
# Copyright (C) 2019 Ultimaker B.V.

set -eu

DOCKER_BUILD_ONLY_CACHE="${DOCKER_BUILD_ONLY_CACHE:-no}"
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-framebuffer-vncserver}"
DOCKER_REGISTRY_NAME="ghcr.io/ultimaker/${DOCKER_IMAGE_NAME}"

echo "Checking for image updates"

# Creates a new docker driver named "ultimaker" if it doesnt exist yet.
docker buildx create --name ultimaker --driver=docker-container 2> /dev/null || true

# Build docker images for all required architectures
for arch in "$@"; do
    if [ "${DOCKER_BUILD_ONLY_CACHE}" = "yes" ]; then
        docker buildx build --builder ultimaker --target "${arch}-build" --cache-to "${DOCKER_REGISTRY_NAME}-${arch}" --cache-from "${DOCKER_REGISTRY_NAME}-${arch}" -f docker_env/Dockerfile -t "${DOCKER_IMAGE_NAME}-${arch}" .
    else
        docker buildx build --builder ultimaker --target "${arch}-build" --load --cache-from "${DOCKER_REGISTRY_NAME}-${arch}" -f docker_env/Dockerfile -t "${DOCKER_IMAGE_NAME}-${arch}" .
        if ! docker run --rm --privileged "${DOCKER_IMAGE_NAME}-${arch}" "./buildenv_check.sh"; then
            echo "Something is wrong with the build environment for ${DOCKER_IMAGE_NAME}-${arch}, please check your Dockerfile."
            docker image rm "${DOCKER_IMAGE_NAME}-${arch}"
            exit 1
        fi
    fi;
done;

DOCKER_WORK_DIR="${WORKDIR:-/build}"
PREFIX="/usr"

run_in_docker()
{
    ARCH="${1}"
    shift 1
    echo "Running '${*}' in docker for arch ${ARCH}."
    # In order to have color in the terminal when running a local build, we need to attach a tty to the docker,
    # but that will fail in CI. So we first check if we have a tty and then add the "-t" argument. The
    # standart input attach ("-i") is safe to keep there, even in CI.
    terminal_arg="-i";
    if tty; then
        terminal_arg="-it"        
    fi;
    
    PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}${DOCKER_WORK_DIR}"
    docker run \
        --rm \
        --privileged \
        "${terminal_arg}" \
        -v "$(pwd):${DOCKER_WORK_DIR}" \
        -u "$(id -u "${USER}"):$(id -g "${USER}")" \
        -e "PREFIX=${PREFIX}" \
        -e "RELEASE_VERSION=${RELEASE_VERSION:-}" \
        -e "ARCH=${ARCH:-}" \
        -w "${DOCKER_WORK_DIR}" \
        "${DOCKER_IMAGE_NAME}-${ARCH}" \
        "${@}"
}
