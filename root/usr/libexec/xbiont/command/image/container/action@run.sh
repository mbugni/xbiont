#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-container/action@run: create the builder container

x::export_with_default 'X_IMAGE_TEMPLATE_DIR'   "$(pwd)/template"
x::export_with_default 'X_CONTAINER_SOURCE_DIR' "$X_IMAGE_TEMPLATE_DIR/podman"

source "$X_CONTAINER_SOURCE_DIR/variables.sh"
x::export_with_default 'X_CONTAINER_PLATFORM' "linux/amd64"

sudo podman build \
    --platform "${X_CONTAINER_PLATFORM}" \
    --tag "${X_CONTAINER_TAG}" \
    "$X_CONTAINER_SOURCE_DIR"
