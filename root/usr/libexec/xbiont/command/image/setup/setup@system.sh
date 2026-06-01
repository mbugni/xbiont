#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/setup@system: basic system image setup

x::log_info 'Setting up system image'

source /.profile

echo 'Setting up root user account'
passwd -d root		# Clear the root user password
passwd -l root		# Lock the root user account

if [ -f /etc/machine-id ]; then
	echo 'Clear machine-id on pre generated images'
	truncate -s 0 /etc/machine-id
fi

if [[ "$kiwi_profiles" == *"LiveSystemGraphical"* ]]; then
	echo 'Setup graphical system'
	systemctl set-default graphical.target
else
	echo 'Setup console system'
	systemctl set-default multi-user.target
fi

x::log_info 'Enable xbiont services'

mkdir -p /etc/systemd/system
cp ${X_ACTIONABLE_DIR}/config/systemd/*-system-*.* /etc/systemd/system/
cp ${X_ACTIONABLE_DIR}/config/systemd/*-zram-*.* /etc/systemd/system/

systemctl enable xbiont-system-setup.service
systemctl enable xbiont-system-cleanup.timer
systemctl enable xbiont-zram-setup.service

if [ "$(systemctl get-default)" = 'graphical.target' ]; then
	mkdir -p /etc/systemd/user
	cp ${X_ACTIONABLE_DIR}/config/systemd/*-session-*.* /etc/systemd/user/
	x::log_info 'Enable graphical system setup'
	systemctl --global enable xbiont-session-setup.service
fi
