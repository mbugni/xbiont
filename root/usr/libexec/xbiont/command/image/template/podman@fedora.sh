#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-template/podman@fedora: create podman files for Fedora

export X_CONTAINER_TAG="xbiont:${X_DISTRO_ID}-${X_DISTRO_VERSION}"
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
    '$X_CONTAINER_TAG'

cp "${X_TEMPLATE_PODMAN_DIR}/entrypoint.sh" \
    "${X_TEMPLATE_TARGET_DIR}/podman"
