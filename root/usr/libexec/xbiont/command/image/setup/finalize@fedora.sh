#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/finalize@fedora: finalize Fedora image configuration

x::log_info "Finalize ${X_DISTRO_ID} ${X_DISTRO_VERSION} image configuration"

echo 'Cleaning dnf cache...'
dnf clean all

echo 'Cleaning rpm database...'
rm -f /var/lib/rpm/__db*
