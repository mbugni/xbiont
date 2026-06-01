#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-cleanup/cleanup@centos: remove unnecessary stuff, if present

function x::remove_with_low_priority() {
    ionice -c 2 -n 5 nice -n 15 dnf remove --assumeyes --cacheonly --disablerepo='*' "$@"
}

function x::is_package_installed() {
    rpm -q "$1" &> /dev/null
}

if x::is_package_installed 'anaconda-core'; then
    x::log_info 'Removing installation tools...'
    x::remove_with_low_priority "anaconda*" dracut-live dracut-squash
    if [ $? -eq 0 ]; then
        rm -rf /etc/anaconda
        rm -rf /var/log/anaconda
    else
        x::log_error 'Installation tools cleanup failed'
    fi
fi

[ "$X_SYSTEM_RUNTIME" = 'physical' ] || exit 0

if x::is_package_installed 'qemu-guest-agent'; then
    x::log_info 'Removing virtualization agents...'
    x::remove_with_low_priority qemu-guest-agent spice-vdagent
    [ $? -eq 0 ] || x::log_error 'Virtualization agents cleanup failed'
fi
