#!/bin/bash

set -eu

# common directory variables
SRC_DIR="$(pwd)"
BUILD_DIR_TEMPLATE="_build"
BUILD_DIR="${BUILD_DIR:-${SRC_DIR}/${BUILD_DIR_TEMPLATE}}"

# Debian package information
PACKAGE_NAME="${PACKAGE_NAME:-framebuffer-vncserver}"
RELEASE_VERSION="${RELEASE_VERSION:-999.999.999}"

NUM_CPUS=$(nproc)

# Defaults to none, so we can catch a missing arch variable
ARCH="${ARCH:-none}"

# Cross-compiling for the desired arch
build()
{
    rm -rf "${BUILD_DIR}_${ARCH}"
    echo -e "\n\n\n===== Building with cmake for ${ARCH}. Using ${NUM_CPUS} cpu cores =====\n"
    cmake -DCMAKE_TOOLCHAIN_FILE="${SRC_DIR}/${ARCH}-toolchain.cmake" . -B "${BUILD_DIR}_${ARCH}"
    cmake --build "${BUILD_DIR}_${ARCH}" -j "${NUM_CPUS}"
}

create_debian_package()
{
    DEB_DIR="${BUILD_DIR}_${ARCH}/debian_deb_build"
    rm -rf "${DEB_DIR}"
    mkdir -p "${DEB_DIR}/DEBIAN"
    sed -e 's|@ARCH@|'"${ARCH}"'|g' \
       -e 's|@PACKAGE_NAME@|'"${PACKAGE_NAME}"'|g' \
       -e 's|@RELEASE_VERSION@|'"${RELEASE_VERSION}"'|g' \
       "${SRC_DIR}/debian/control.in" > "${DEB_DIR}/DEBIAN/control"


    TARGET_FOLDER="${DEB_DIR}/usr/bin/"
    mkdir -p "${TARGET_FOLDER}" 
    cp "${BUILD_DIR}_${ARCH}/framebuffer-vncserver" "${TARGET_FOLDER}"
    cp "${SRC_DIR}/debian/postinst" "${DEB_DIR}/DEBIAN/"

    DEB_PACKAGE="${PACKAGE_NAME}_${RELEASE_VERSION}_${ARCH}.deb"

    dpkg-deb --build --root-owner-group "${DEB_DIR}" "${SRC_DIR}/${DEB_PACKAGE}"
    dpkg-deb -c "${SRC_DIR}/${DEB_PACKAGE}"
}

cleanup()
{
    rm -rf "${BUILD_DIR}"_*
}

usage()
{
    echo "Usage: ${0} [OPTIONS]"
    echo "  -c   Explicitly cleanup the build directory"
    echo "  -h   Print this usage"
    echo "NOTE: This script requires root permissions to run."
}

while getopts ":hc" options; do
    case "${options}" in
    c)
        cleanup
        exit 0
        ;;
    h)
        usage
        exit 0
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

if [ "${ARCH}" == "none" ]; then
    echo "ERROR: You must provide an ARCH variable with the target architecture to compile the source code"
    exit 1
fi;

build
create_debian_package

exit 0
