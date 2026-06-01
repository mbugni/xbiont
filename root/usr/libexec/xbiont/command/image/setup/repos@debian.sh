#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/repos@debian: setup repositories for Debian image

source /etc/os-release

function x::setup_trinity_repo() {
	local repo_file="/etc/apt/sources.list.d/trinity-desktop.list"

	echo "Importing Trinity GPG signing key..."
	wget http://mirror.ppa.trinitydesktop.org/trinity/deb/trinity-keyring.deb && \
	dpkg --install trinity-keyring.deb && rm trinity-keyring.deb
	echo "Adding repository to $repo_file..."
	cat << EOF > "$repo_file"
# TDE R14.1.x series
deb http://mirror.ppa.trinitydesktop.org/trinity/deb/trinity-r14.1.x $VERSION_CODENAME main deps
#deb-src http://mirror.ppa.trinitydesktop.org/trinity/deb/trinity-r14.1.x $VERSION_CODENAME main deps
EOF
}

if [ "$X_DESKTOP_CODENAME" = 'trinity' ]; then
    x::setup_trinity_repo
fi
