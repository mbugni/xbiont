#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@install: run the image installer procedure

source "$X_ACTIONABLE_DIR/wizard@summary.sh"
export X_INSTALL_TARGET_ROOT=/mnt/target
steps=(partitioning formatting mounting copying boot-setup configuration post-installation)
ranges=(5 15 30 40 75 90 97 100)
for i in "${!steps[@]}"; do
    export X_INSTALL_STEP=${steps[i]}
    export X_INSTALL_PERCENTAGE_MIN=${ranges[i]}
    export X_INSTALL_PERCENTAGE_MAX=${ranges[i+1]}
    script="$X_ACTIONABLE_DIR/install@${steps[i]}.sh"
    test -r "$script"
    ( source "$script" )
done
jq -cn '{version:1,type:"completed",success:true,execution:"dryrun"}'
