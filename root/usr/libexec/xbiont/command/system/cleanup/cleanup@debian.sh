#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-cleanup/cleanup@debian: remove unnecessary stuff, if present

function x::remove_with_low_priority() {
    ionice -c 2 -n 5 nice -n 15 apt-get autopurge --assume-yes --no-download "$@"
}

function x::is_package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'installed'
}

x::log_info 'Cleaning unneeded packages...'
apt-get autopurge --assume-yes --no-download

if x::is_package_installed 'calamares*'; then
    echo 'Removing installation tools...'
    packages_to_remove="calamares*"
    
    if [ "$X_DISTRO_VERSION" -le 11 ]; then
        # Old versions don't require dracut
        packages_to_remove="$packages_to_remove dracut*"
    else
        # Remove live dracut modules
        packages_to_remove="$packages_to_remove dracut-live dracut-squash"
    fi

    echo "Removing packages: $packages_to_remove"
    x::remove_with_low_priority $packages_to_remove
    [ $? -eq 0 ] || echo 'Installation tools cleanup failed'
fi

[ "$X_SYSTEM_RUNTIME" = 'physical' ] || exit 0

if x::is_package_installed 'qemu-guest-agent'; then
    echo 'Removing virtualization agents...'
    x::remove_with_low_priority qemu-guest-agent spice-vdagent xserver-xorg-video-qxl
    [ $? -eq 0 ] || echo 'Virtualization agents cleanup failed'
fi
