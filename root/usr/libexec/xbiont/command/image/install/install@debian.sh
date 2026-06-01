#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/install@debian: run the image installer for Debian

installer_elevator="$(find /usr/lib -name kdesu)"

if [ -n "$installer_elevator" ]; then
    x::log_info "Found elevator: $installer_elevator"
    $installer_elevator -c 'calamares -D6'
elif [ -x /opt/trinity/bin/tdesu ]; then
    x::log_info "Found elevator: tdesu"
    /opt/trinity/bin/tdesu 'calamares -D6'
else
    x::log_error "No suitable elevator found"
    exit 1
fi
