#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-cleanup/action@run.sh: remove unnecessary stuff, if present

[ "$X_SYSTEM_LIFECYCLE" = 'installed' ] || exit 0

if [ -e /.profile ]; then
    x::log_info 'Cleaning live residuals...'
    rm -f /.profile
    [ -e /.kconfig ] && rm -f /.kconfig
fi

for image_log_file in /var/log/xbiont/command/image*.log; do
    rm -f "$image_log_file"
done

x::execute_activations "cleanup@${X_DISTRO_ID}.sh" 
