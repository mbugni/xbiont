#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-template/prepare@seat: prepare seat configuration

x::log_info 'Copying console configuration...'
x::copy_and_resolve \
    "${X_TEMPLATE_CONFIG_DIR}/console" \
    "${X_TEMPLATE_TARGET_DIR}/kiwi-ng/root"

x::log_info 'Copying desktop configuration...'
x::copy_and_resolve \
    "${X_TEMPLATE_CONFIG_DIR}/desktop/${X_DESKTOP_CODENAME}/${X_DESKTOP_VERSION}" \
    "${X_TEMPLATE_TARGET_DIR}/kiwi-ng/root"
