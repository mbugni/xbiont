#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-prepare/action@run: create image files for building

if [ ! -d "${X_TEMPLATE_CONFIG_DIR}/distro/${X_DISTRO_ID}/${X_DISTRO_VERSION}" ]; then
    x::log_error "Fatal: distro '${X_DISTRO_ID} ${X_DISTRO_VERSION}' not supported"
    exit 1
fi

source "${X_TEMPLATE_CONFIG_DIR}/distro/${X_DISTRO_ID}/${X_DISTRO_VERSION}/variables.sh"

x::export_with_default 'X_IMAGE_VOLUME_ID' "Xbiont_${X_DISTRO_NAME:0:3}${X_DISTRO_VERSION}"

mkdir -p "$X_TEMPLATE_TARGET_DIR"

x::execute_activations \
    "prepare@seat.sh" \
    "prepare@kiwi-ng.sh" \
    "podman@${X_DISTRO_ID}.sh"

x::log_info 'Copying xbiont command...'
x::install_file "${X_PULSE_DIR}/xbiont" "$X_TEMPLATE_TARGET_DIR/kiwi-ng/root/usr/bin/xbiont"

x::log_info 'Copying xbiont core directory...'
mkdir -p "$X_TEMPLATE_TARGET_DIR/kiwi-ng/root/usr/libexec"
cp -R "${X_CORE_DIR}" "${X_TEMPLATE_TARGET_DIR}/kiwi-ng/root/usr/libexec"