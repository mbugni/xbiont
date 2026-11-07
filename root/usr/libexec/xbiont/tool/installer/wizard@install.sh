#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/wizard@install: run the image installer procedure

# Recheck the plan before making any change; aborts on invalid selections
source "$X_ACTIONABLE_DIR/wizard@summary.sh"

export X_INSTALL_TARGET_ROOT=/mnt/target
export X_INSTALL_LIVE_IMAGE=${X_INSTALL_LIVE_IMAGE:-/dev/mapper/live-base}
export X_INSTALL_LIVE_SOURCE=${X_INSTALL_LIVE_SOURCE:-/run/install-source}
export X_INSTALL_STATE_FILE=${X_INSTALL_STATE_FILE:-$(mktemp /tmp/xbiont-install-XXXXXX.env)}
: > "$X_INSTALL_STATE_FILE"
trap 'rm -f "$X_INSTALL_STATE_FILE"' EXIT

# Step order follows the live-image install pipeline: fstab and regional
# settings (late storage/OS configuration) precede bootloader setup, so the
# initramfs is regenerated only after every configuration is in place
steps=(partitioning formatting mounting copying configuration boot-setup post-installation)
ranges=(5 15 30 40 80 90 96 100)
for i in "${!steps[@]}"; do
    export X_INSTALL_STEP=${steps[i]}
    export X_INSTALL_PERCENTAGE_MIN=${ranges[i]}
    export X_INSTALL_PERCENTAGE_MAX=${ranges[i+1]}
    script="$X_ACTIONABLE_DIR/install@${steps[i]}.sh"
    if [ ! -r "$script" ]; then
        x::install_error missing_step "Install step '$X_INSTALL_STEP' is not implemented"
        exit 1
    fi
    if ! ( x::install_state_load; source "$script" ); then
        x::install_error step_failed "Step '$X_INSTALL_STEP' failed"
        exit 1
    fi
done
jq -cn --arg execution "$X_INSTALL_EXECUTION" '{version:1,type:"completed",success:true,execution:$execution}'
