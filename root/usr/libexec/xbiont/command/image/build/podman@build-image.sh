#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/podman@build-image: build the image builder container

x::export_with_default 'X_CONTAINER_SOURCE_DIR' "$X_ACTIONABLE_DIR/config"

sudo podman build \
    --platform "${X_CONTAINER_PLATFORM}" \
    --file "$X_CONTAINER_SOURCE_DIR/Containerfile.${X_DISTRO_ID}" \
    --build-arg="X_IMAGE_PLATFORM=${X_IMAGE_PLATFORM}" \
    --tag "${X_CONTAINER_TAG}" \
    --target "${X_DISTRO_CODE}-${X_IMAGE_PLATFORM}" \
    "$X_CONTAINER_SOURCE_DIR"
