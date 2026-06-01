#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# variables: define common system variables

if [ -z "${X_SYSTEM_LIFECYCLE}" ]; then
    if grep -q "rd.live.image" /proc/cmdline; then
        export X_SYSTEM_LIFECYCLE="live"
    else
        export X_SYSTEM_LIFECYCLE="installed"
    fi
fi

if [ -z "${X_SYSTEM_RUNTIME}" ]; then
    if systemd-detect-virt -q; then
        export X_SYSTEM_RUNTIME="virtual"
    else
        export X_SYSTEM_RUNTIME="physical"
    fi
fi

[ -n "${X_MACHINE_MANUFACTURER}" ] || \
    export X_MACHINE_MANUFACTURER=$(cat /sys/class/dmi/id/sys_vendor | tr '[:upper:]' '[:lower:]')

[ -n "${X_DISTRO_ID}" ] || \
    export X_DISTRO_ID=$(source /etc/os-release && echo $ID)

[ -n "${X_DISTRO_VERSION}" ] || \
    export X_DISTRO_VERSION=$(source /etc/os-release && echo $VERSION_ID)
