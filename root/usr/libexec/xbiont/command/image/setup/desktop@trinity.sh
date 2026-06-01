#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/desktop@trinity: configure Trinity desktop

x::log_info 'Configuring Trinity desktop'

echo 'Enable TDM login manager'
systemctl enable tdm.service

if [ "$X_SEAT_KEYTABLE" != 'us' ]; then
	echo "Setup Trinity keyboard ${X_SEAT_KEYTABLE} ${X_SEAT_KEYMODEL}"
	sed -i 's/^LayoutList=.*/LayoutList='${X_SEAT_KEYTABLE}'/' /etc/trinity/kxkbrc
	sed -i 's/^Model=.*/Model='${X_SEAT_KEYMODEL}'/' /etc/trinity/kxkbrc
fi
