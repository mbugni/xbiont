#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/desktop@plasma: configure Plasma desktop

x::log_info 'Configuring Plasma desktop'

echo 'Enable SDDM login manager'
systemctl enable sddm.service

if [ "$X_SEAT_KEYTABLE" != 'us' ]; then
	echo "Setup Plasma keyboard ${X_SEAT_KEYTABLE} ${X_SEAT_KEYMODEL}"
	echo "[Layout]" > /etc/xdg/kxkbrc
	echo "LayoutList=${X_SEAT_KEYTABLE}" >> /etc/xdg/kxkbrc
	echo "Model=${X_SEAT_KEYMODEL}" >> /etc/xdg/kxkbrc
	echo "Use=true" >> /etc/xdg/kxkbrc
fi
