#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-template/podman@debian: create podman files for Debian

if [ "$X_IMAGE_PLATFORM" = 'i686' ]; then
    export X_CONTAINER_REGISTRY="docker.io/i386/debian"
    export X_CONTAINER_PLATFORM="linux/386"
else
    export X_CONTAINER_REGISTRY="docker.io/debian"    
    export X_CONTAINER_PLATFORM="linux/amd64"
fi

export X_CONTAINER_TAG="xbiont:${X_DISTRO_ID}-${X_DISTRO_VERSION}-${X_IMAGE_PLATFORM}"

if [ "$X_DISTRO_VERSION" -ge '12' ]; then
    export X_PIP3_OPTIONS="--break-system-packages"
else
    export X_PIP3_OPTIONS=""
fi

export X_TEMPLATE_PODMAN_DIR="${X_TEMPLATE_CONFIG_DIR}/distro/${X_DISTRO_ID}/podman"

x::copy_and_resolve \
    "${X_TEMPLATE_PODMAN_DIR}/variables.sh" \
    "${X_TEMPLATE_TARGET_DIR}/podman" \
    '$X_DISTRO_ID' \
    '$X_DISTRO_VERSION' \
    '$X_CONTAINER_PLATFORM' \
    '$X_CONTAINER_REGISTRY' \
    '$X_CONTAINER_TAG' \
    '$X_IMAGE_PLATFORM' \
    '$X_IMAGE_NAME' \
    '$X_IMAGE_VERSION' \
    '$X_IMAGE_VOLUME_ID' \
    '$X_SEAT_LOCALE'

x::copy_and_resolve \
    "${X_TEMPLATE_PODMAN_DIR}/Containerfile" \
    "${X_TEMPLATE_TARGET_DIR}/podman" \
    '$X_DISTRO_ID' \
    '$X_DISTRO_VERSION' \
    '$X_CONTAINER_PLATFORM' \
    '$X_CONTAINER_REGISTRY' \
    '$X_CONTAINER_TAG' \
    '$X_PIP3_OPTIONS'

cp "${X_TEMPLATE_PODMAN_DIR}/entrypoint.sh" \
    "${X_TEMPLATE_TARGET_DIR}/podman"
