#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/exec@system-prepare.sh: run the image prepare process using kiwi

$(x::kiwi_cmd) \
    --type=iso --debug --color-output \
    --profile="${X_BUILD_PROFILE}" \
    --shared-cache-dir="${X_BUILD_TARGET_DIR}/cache" \
    system prepare \
    --description="${X_BUILD_KIWING_DIR}" \
    --root="${X_BUILD_TARGET_DIR}/build/image-root"
