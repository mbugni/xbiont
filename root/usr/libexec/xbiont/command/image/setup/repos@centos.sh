#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/repos@centos: setup repositories for CentOS image

echo 'Importing GPG keys'
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-*
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-*

echo 'Disabling weak dependencies installation'
echo "install_weak_deps=False" >> /etc/dnf/dnf.conf

echo 'Enable CRB (previously named PowerTools) repo'
dnf config-manager --set-enabled crb

if [ "$(systemctl is-enabled flatpak-add-fedora-repos)" = 'enabled' ]; then
	echo 'Disabling additional Fedora Flatpak repos'
	systemctl disable flatpak-add-fedora-repos
fi
