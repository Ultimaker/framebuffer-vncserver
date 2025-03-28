#!/bin/bash

set -eu

# common directory variables
SYSCONFDIR="${SYSCONFDIR:-/etc}"
SRC_DIR="$(pwd)"
PACKAGE_NAME="${PACKAGE_NAME:-framebuffer-vncserver}"
RELEASE_VERSION="${RELEASE_VERSION:-999.999.999}"

create_debian_package()
{
    make package
}

build()
{
    local ARCH="${1}"
    local BUILD_DIR="${SRC_DIR}/_build_${ARCH}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}" || return
    rm -f ./*.deb

    # Create Debian control files
    mkdir -p "${BUILD_DIR}/DEBIAN"
    sed -e 's|@RELEASE_VERSION@|'"${RELEASE_VERSION}"'|g' \
        -e 's|@ARCH@|'"${ARCH}"'|g' \
       "${SRC_DIR}/debian/control.in" > "${BUILD_DIR}/DEBIAN/control"
    cp "${SRC_DIR}/debian/postinst" "${BUILD_DIR}/DEBIAN/"

    echo "Building for ${ARCH} with cmake"
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
             -DCPACK_PACKAGE_VERSION="${RELEASE_VERSION}" \
             -DCPACK_PACKAGE_NAME="${PACKAGE_NAME}" \
             -DCPACK_PACKAGE_ARCH="${ARCH}"
    create_debian_package
}

build "$1"
