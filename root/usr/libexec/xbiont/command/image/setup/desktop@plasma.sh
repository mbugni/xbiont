#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/desktop@plasma: configure Plasma desktop

x::log_info 'Configuring Plasma desktop'

if [ -n "$(systemctl status sddm.service 2> /dev/null)" ]; then
	echo 'Enabling SDDM service'
	systemctl enable sddm.service
else
	echo 'Enabling plasmalogin service'
	systemctl enable plasmalogin.service
fi

if [ "$X_SEAT_KEYTABLE" != 'us' ]; then
	echo "Setup Plasma keyboard ${X_SEAT_KEYTABLE} ${X_SEAT_KEYMODEL}"
	echo "[Layout]" > /etc/xdg/kxkbrc
	echo "LayoutList=${X_SEAT_KEYTABLE}" >> /etc/xdg/kxkbrc
	echo "Model=${X_SEAT_KEYMODEL}" >> /etc/xdg/kxkbrc
	echo "Use=true" >> /etc/xdg/kxkbrc
fi
