#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-setup/seat@live: setup live user interaction

if [ -f /etc/default/keyboard ]; then
    source /etc/default/keyboard
    echo "Setup X11 keyboard: $XKBLAYOUT $XKBMODEL"
    localectl set-x11-keymap $XKBLAYOUT $XKBMODEL
fi

x::execute_activations "config/live/${X_DISTRO_ID}/setup@seat.sh"
