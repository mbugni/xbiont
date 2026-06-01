#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# live-debian/setup@seat: setup live interaction for Debian

function x::setup_installer_application() {
    echo 'Hide original installer action'
    desktop-file-edit --set-key=Hidden --set-value=true /usr/share/applications/install-debian.desktop

    echo 'Hide original installer icon'
    desktop-file-edit --set-key=Hidden --set-value=true /etc/xdg/autostart/calamares-desktop-icon.desktop

    echo 'Rename installer launcher'
    mv /usr/share/applications/calamares.desktop.orig /usr/share/applications/image-install.desktop

    echo 'Adjust installer launcher'
    installer_cmd="/usr/bin/xbiont image install"
    desktop-file-edit --set-key=Exec --set-value="$installer_cmd" /usr/share/applications/image-install.desktop

    echo 'Setup Calamares settings'
    mkdir -p /etc/calamares
    cp --archive \
        ${X_ACTIONABLE_DIR}/config/live/${X_DISTRO_ID}/${X_DISTRO_VERSION}/calamares/* \
        /etc/calamares/
}

if [ -f /etc/xdg/autostart/org.kde.discover.notifier.desktop ]; then
    echo 'Disable plasma-discover-notifier'
    desktop-file-edit --set-key=Hidden --set-value=true /etc/xdg/autostart/org.kde.discover.notifier.desktop
fi

if [ ! -f /usr/share/applications/image-install.desktop ]; then
    x::setup_installer_application
fi