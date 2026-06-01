#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/setup@network: configure live image networking

x::log_info "Setup networking for ${X_SYSTEM_HOSTNAME}"

echo "${X_SYSTEM_HOSTNAME}" > /etc/hostname

if [[ "$(systemctl is-enabled systemd-resolved.service)" != 'enabled' ]]; then
	echo 'Ensure hostname is resolvable'
	echo "127.0.0.1 ${X_SYSTEM_HOSTNAME}" >> /etc/hosts
fi

if [[ "$(systemctl is-enabled NetworkManager.service)" != 'enabled' ]]; then
	echo 'Enable NetworkManager service'
	systemctl enable NetworkManager.service
fi
