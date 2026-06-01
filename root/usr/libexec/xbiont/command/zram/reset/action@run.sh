#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# zram-reset/action@run: reset zram

x::log_info "Resetting zram..."

if swapon --show | grep -q "/dev/zram0"; then
    swapoff /dev/zram0
fi
if [ -b /dev/zram0 ]; then
    zramctl --reset /dev/zram0
fi

echo "/dev/zram0 deactivated"