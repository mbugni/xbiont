#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/exec@podman-run.sh: run the command in a container

source "${X_BUILD_TEMPLATE_DIR}/podman/variables.sh"

selinux_enforce=''
if command -v getenforce &> /dev/null; then
    selinux_enforce="$(getenforce)"
    if [ "$selinux_enforce" = 'Enforcing' ]; then
        echo "Temporarily disabling SELinux for container operations"
        setenforce 0
    else
        selinux_enforce=''
    fi
fi

sudo podman run --rm \
    --privileged \
    --restart=no \
    --platform="$X_CONTAINER_PLATFORM" \
    --device=/dev/loop-control \
    --volume="${X_BUILD_KIWING_DIR}:/image/source:ro" \
    --volume="${X_BUILD_TARGET_DIR}:/image/target" \
    --env X_IMAGE_PLATFORM="${X_IMAGE_PLATFORM}" \
    --env X_IMAGE_NAME="${X_IMAGE_NAME}" \
    --env X_IMAGE_VERSION="${X_IMAGE_VERSION}" \
    --env X_SEAT_PLATFORM="${X_SEAT_PLATFORM}" \
    --env X_SEAT_LOCALE="${X_SEAT_LOCALE}" \
    --env X_BUILD_KIWING_DIR="/image/source" \
    --env X_BUILD_TARGET_DIR="/image/target" \
    --env X_BUILD_COMMAND="${X_BUILD_COMMAND}" \
    ${X_CONTAINER_TAG}

if [ -n "$selinux_enforce" ]; then
    # Restore original SELinux status
    setenforce "$selinux_enforce"
fi
