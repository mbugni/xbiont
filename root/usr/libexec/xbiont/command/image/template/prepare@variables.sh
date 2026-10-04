#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-template/prepare@variables: create variables file for template

x::copy_and_resolve \
    "${X_TEMPLATE_CONFIG_DIR}/variables.sh" \
    "${X_TEMPLATE_TARGET_DIR}" \
    '$X_DISTRO_ID' \
    '$X_DISTRO_NAME' \
    '$X_DISTRO_VERSION' \
    '$X_DISTRO_CODE' \
    '$X_DISTRO_CODENAME' \
    '$X_IMAGE_PLATFORM' \
    '$X_IMAGE_NAME' \
    '$X_IMAGE_VERSION' \
    '$X_SEAT_LOCALE'
