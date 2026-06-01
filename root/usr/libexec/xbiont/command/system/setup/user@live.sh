#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-setup/user@live: ensure liveuser and basic settings

[ "$(id --user --name liveuser)" = "liveuser" ] && exit 0

liveuser_groups=""
for expected_group in 'audio' 'video' 'wheel' 'adm' 'sudo'; do
    if [ -n "$(getent group "$expected_group")" ]; then
        if [ -z "$liveuser_groups" ]; then
            liveuser_groups="$expected_group"
        else
            liveuser_groups="$liveuser_groups,$expected_group"
        fi
    fi
done

x::log_info "Setup liveuser with groups: $liveuser_groups"
## Add liveuser user with no passwd
useradd --comment "Live System User" --create-home --shell /usr/bin/bash liveuser
passwd -d liveuser > /dev/null
usermod -aG $liveuser_groups liveuser > /dev/null
