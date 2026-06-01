#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/finalize@debian: finalize Debian image configuration

x::log_info "Finalize ${X_DISTRO_ID} ${X_DISTRO_VERSION} image configuration"

export APT_LISTCHANGES_FRONTEND=none \
	DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true

# Ensure package registry is consistent
apt-get update && \
	apt-get --assume-yes --fix-broken install && \
	apt-get --assume-yes dist-upgrade

# Hide legacy xterm icons, if any
for legacy_entry in xterm uxterm
do
	if [ -f /usr/share/applications/debian-${legacy_entry}.desktop ]; then
		mkdir -p /usr/local/share/applications
		cp /usr/share/applications/debian-${legacy_entry}.desktop /usr/local/share/applications
		echo 'NoDisplay=true' >> /usr/local/share/applications/debian-${legacy_entry}.desktop
	fi
done

echo 'Clean software management cache'
apt-get clean
