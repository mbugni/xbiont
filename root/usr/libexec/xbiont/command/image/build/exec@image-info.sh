#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/exec@image-info.sh: get image information using kiwi

$(x::kiwi_cmd) \
    --type=iso \
    --profile="${X_BUILD_PROFILE}" \
    image info \
    --description="${X_BUILD_KIWING_DIR}" \
    --print-xml \
    --print-kiwi-env
