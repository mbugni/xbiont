#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/repos@fedora: setup repositories for Fedora image

echo 'Importing GPG keys'
releasever=$(rpm --eval '%{fedora}')
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-primary

echo 'Disabling weak dependencies installation'
echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

if [ "$(systemctl is-enabled flatpak-add-fedora-repos)" = 'enabled' ]; then
	echo 'Disabling additional Fedora Flatpak repos'
	systemctl disable flatpak-add-fedora-repos
fi
