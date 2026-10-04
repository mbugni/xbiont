#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/podman@exec-command: run the build command in a container

function exec_privileged_command() {
    
    local selinux_enforce=''

    if command -v getenforce &> /dev/null; then
        selinux_enforce="$(getenforce)"
        if [ "$selinux_enforce" = 'Enforcing' ]; then
            echo "Temporarily disabling SELinux for container operations"
            setenforce 0
        else
            selinux_enforce=''
        fi
    fi

    podman run --rm \
        --pull=never \
        --privileged \
        --security-opt label=disable \
        --restart=no \
        --platform="$X_CONTAINER_PLATFORM" \
        --device=/dev/loop-control \
        --volume="${X_BUILD_KIWING_DIR}:/image/source:ro" \
        --volume="${X_BUILD_TARGET_DIR}:/image/target" \
        --volume="${X_BUILD_TARGET_DIR}/tmp:/var/tmp:rw" \
        --env=X_IMAGE_PLATFORM="${X_IMAGE_PLATFORM}" \
        --env=X_IMAGE_NAME="${X_IMAGE_NAME}" \
        --env=X_IMAGE_VERSION="${X_IMAGE_VERSION}" \
        --env=X_SEAT_PLATFORM="${X_SEAT_PLATFORM}" \
        --env=X_SEAT_LOCALE="${X_SEAT_LOCALE}" \
        --env=X_BUILD_KIWING_DIR="/image/source" \
        --env=X_BUILD_TARGET_DIR="/image/target" \
        --env=X_BUILD_COMMAND="${X_BUILD_COMMAND}" \
        ${X_CONTAINER_TAG}

    if [ -n "$selinux_enforce" ]; then
        # Restore original SELinux status
        setenforce "$selinux_enforce"
    fi
}

mkdir -p "${X_BUILD_TARGET_DIR}/tmp"

export -f exec_privileged_command
X_BUILD_PRIVILEGED_COMMAND="$(declare -f exec_privileged_command)"

# Run the function in a sudo shell with environment variables
sudo \
  X_CONTAINER_PLATFORM="$X_CONTAINER_PLATFORM" \
  X_BUILD_KIWING_DIR="$X_BUILD_KIWING_DIR" \
  X_BUILD_TARGET_DIR="$X_BUILD_TARGET_DIR" \
  X_IMAGE_PLATFORM="$X_IMAGE_PLATFORM" \
  X_IMAGE_NAME="$X_IMAGE_NAME" \
  X_IMAGE_VERSION="$X_IMAGE_VERSION" \
  X_SEAT_PLATFORM="$X_SEAT_PLATFORM" \
  X_SEAT_LOCALE="$X_SEAT_LOCALE" \
  X_BUILD_COMMAND="$X_BUILD_COMMAND" \
  X_CONTAINER_TAG="$X_CONTAINER_TAG" \
  X_BUILD_PRIVILEGED_COMMAND="$X_BUILD_PRIVILEGED_COMMAND" \
  -s << 'EOF'
eval "$X_BUILD_PRIVILEGED_COMMAND"
exec_privileged_command
EOF
