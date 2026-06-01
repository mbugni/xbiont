#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-template/prepare@kiwi-ng: create kiwi-ng descriptions for the distribution

x::log_info 'Copying kiwi-ng configuration...'
x::copy_and_resolve \
    "${X_TEMPLATE_CONFIG_DIR}/distro/${X_DISTRO_ID}/${X_DISTRO_VERSION}/kiwi-ng" \
    "${X_TEMPLATE_TARGET_DIR}/kiwi-ng" \
    '$X_DISTRO_ID' \
    '$X_DISTRO_NAME' \
    '$X_DISTRO_CODENAME' \
    '$X_DISTRO_VERSION' \
    '$X_IMAGE_NAME'\
    '$X_IMAGE_NAME' \
    '$X_IMAGE_VERSION' \
    '$X_IMAGE_VOLUME_ID' \
    '$X_SEAT_LOCALE' \
    '$X_SEAT_KEYTABLE' \
    '$X_SEAT_KEYMODEL' \
    '$X_SEAT_TIMEZONE'
