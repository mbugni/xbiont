#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/module-functions: common build functions

function x::kiwi_cmd() {
    if [ "$X_IMAGE_PLATFORM" = 'i686' ]; then
        echo 'linux32 kiwi-ng'
    else
        echo 'kiwi-ng'
    fi
}
