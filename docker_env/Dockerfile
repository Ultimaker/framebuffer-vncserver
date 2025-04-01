# ===== Stage 1: Build environment for ARM64 =====
FROM debian:bullseye-slim AS arm64-build

# Install the build tools for cross compiling ARM64
RUN dpkg --add-architecture arm64 && apt update && apt-get install -y \
        build-essential \
        cmake  \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        libvncserver-dev:arm64 \
        && \
        apt-get clean && \
        rm -rf /var/cache/apt/* && \
        rm -rf /var/lib/apt/*

COPY docker_env/buildenv_check.sh buildenv_check.sh

# ===== Stage 2: Build environment for ARMHF =====
FROM debian:bullseye AS armhf-build

# Install the build tools for cross compiling
RUN dpkg --add-architecture armhf && apt update && apt-get install -y \
        build-essential \
        cmake  \
        gcc-arm-linux-gnueabihf \
        g++-arm-linux-gnueabihf \
        libvncserver-dev:armhf \
        && \
        apt-get clean && \
        rm -rf /var/cache/apt/* && \
        rm -rf /var/lib/apt/*

COPY docker_env/buildenv_check.sh buildenv_check.sh
