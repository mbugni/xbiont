#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/setup@seat: configure live image user interaction

echo "Setup default boot theme ${X_PLYMOUTH_THEME}"
/usr/sbin/plymouth-set-default-theme "${X_PLYMOUTH_THEME}"

if [ -f /etc/default/keyboard ]; then
	echo "Setup system keyboard: ${X_SEAT_KEYTABLE} ${X_SEAT_KEYMODEL}"
	sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="'${X_SEAT_KEYTABLE}'"/' /etc/default/keyboard
	sed -i 's/^XKBMODEL=.*/XKBMODEL="'${X_SEAT_KEYMODEL}'"/' /etc/default/keyboard
fi

if [ "$X_SEAT_LOCALE" != 'en_US' ]; then
	system_locale="${X_SEAT_LOCALE}.UTF-8"
	echo "Set up system locale: ${system_locale}"
	echo "LANG=${system_locale}" > /etc/default/locale
fi

echo 'Setup history search in terminal'
if grep -q 'history-search-backward' /etc/inputrc; then
	sed -i 's/# "\\e\[5~": history-search-backward/"\\e\[5~": history-search-backward/' /etc/inputrc
	sed -i 's/# "\\e\[6~": history-search-forward/"\\e\[6~": history-search-forward/' /etc/inputrc
else
	echo '"\e[5~": history-search-backward' >> /etc/inputrc
	echo '"\e[6~": history-search-forward' >> /etc/inputrc
fi

if command -v flatpak &> /dev/null; then
	echo 'Setting up Flathub repo'
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	if [ "${X_SEAT_PLATFORM^}" = 'Workstation' ]; then
		echo 'Installing Firefox from Flathub'
		flatpak install --assumeyes --noninteractive flathub org.mozilla.firefox
	fi
fi
