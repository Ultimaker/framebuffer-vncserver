#!/bin/bash
#
# Copyright (C) 2019 Ultimaker B.V.
#

set -eu

RELEASE_VERSION="${RELEASE_VERSION:-9999.99.99}"
DOCKER_WORK_DIR="/build"

SHELLCHECK_IMAGE="registry.hub.docker.com/koalaman/shellcheck-alpine:stable"

# Build packages for this list of architectures.
# Must have support both in the Dockerfile and cmake files.
ARCHS="arm64 armhf"

run_linters="yes"
action="none"

run_linting()
{
    # In order to display colors in a local terminal, we need to attach a tty to the docker,
    # but that will fail in CI. So we first check if we have a tty and then add the "-t" argument.
    terminal_arg="-i";
    if tty; then
        terminal_arg="-it"        
    fi;    
    docker run \
        --rm \
        "${terminal_arg}" \
        -u "$(id -u):$(id -g)" \
        -v "$(pwd):${DOCKER_WORK_DIR}" \
        -v /etc/localtime:/etc/localtime:ro \
        -v /etc/timezone:/etc/timezone:ro \
        -w "${DOCKER_WORK_DIR}" \
        "${@}"
}

run_verification()
{
    echo "Testing!"
    run_linting "${SHELLCHECK_IMAGE}" "./shellcheck.sh"
}

usage()
{
    echo "Usage: ${0} [OPTIONS]"
    echo "  -h   Print usage"
    echo "  -s   Skip code verification"
}

build()
{
    # shellcheck disable=SC2086
    source ./docker_env/make_docker.sh ${ARCHS}

    for arch in ${ARCHS}; do
        run_in_docker "${arch}" "./build.sh"
    done;
}

while getopts ":hlsa:" options; do
    case "${options}" in
    a)
        action="${OPTARG}"
        ;;
    h)
        usage
        exit 0
        ;;
    l)
        run_linters="no"
        ;;
    s)
        run_linters="no"
        ;;
    :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
    ?)
        echo "Invalid option: -${OPTARG}"
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

if ! command -V docker; then
    echo "Docker not found, docker-less builds are not supported."
    exit 1
fi

echo "Action: ${action}"
case "${action}" in
    shellcheck)
        run_linting "${SHELLCHECK_IMAGE}" "./shellcheck.sh"
        exit 0
        ;;
    lint)
        run_verification
        exit 0
        ;;
    build)
        build
        exit 0
        ;;
    build_docker_cache)
        DOCKER_BUILD_ONLY_CACHE="yes"
        # shellcheck disable=SC2086
        source ./docker_env/make_docker.sh ${ARCHS}
        exit 0
        ;;
    none)
        ;;
    *)
        echo "Invalid action: ${action}"
        exit 1
        ;;
esac

if [ "${run_linters}" = "yes" ]; then
    run_verification
fi

build

echo "Success"

exit 0
