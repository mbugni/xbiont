#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/action@run.sh: execute the build command

x::export_with_default 'X_BUILD_TEMPLATE_DIR'   "${X_BUILD_TARGET_DIR}/template"
x::export_with_default 'X_BUILD_KIWING_DIR'     "${X_BUILD_TEMPLATE_DIR}/kiwi-ng"

if [ ! -f "$X_BUILD_TEMPLATE_DIR/variables.sh" ]; then
    x::log_error "Fatal: missing template configuration in $X_BUILD_TEMPLATE_DIR"
    exit 1
fi

source "$X_BUILD_TEMPLATE_DIR/variables.sh"

if [ "$X_IMAGE_PLATFORM" = 'i686' ]; then
    export X_CONTAINER_PLATFORM="linux/386"
else
    export X_CONTAINER_PLATFORM="linux/amd64"
fi

export X_CONTAINER_TAG="xbiont:${X_DISTRO_CODE}-${X_IMAGE_PLATFORM}"

case "$X_BUILD_RUNTIME" in
    podman)
        # Ensure the runtime container is available
        if sudo podman image exists "$X_CONTAINER_TAG"; then
            echo "Using existing image $X_CONTAINER_TAG"
        else
            echo "Image $X_CONTAINER_TAG not found. Starting build container..."
            x::execute_activations "podman@build-image.sh"
        fi
        # Run the command in a podman container
        x::execute_activations "podman@exec-command.sh"
        ;;
    host)
        # Run the command on the current system
        if [ -x "${X_ACTIONABLE_DIR}/exec@${X_BUILD_COMMAND}.sh" ]; then
            x::execute_activations "exec@${X_BUILD_COMMAND}.sh"
        else
            exec "${X_BUILD_COMMAND}"
        fi
        ;;
    *)
        x::log_error "Unknown build runtime: $X_BUILD_RUNTIME"
        exit 1
        ;;
esac
