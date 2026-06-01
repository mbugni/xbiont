#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# live-fedora/setup@seat: setup live interaction for Fedora

function x::setup_installer_application() {
    echo 'Hide original installer icon'
    desktop-file-edit --set-key=Hidden --set-value=true /etc/xdg/autostart/liveinst-setup.desktop

    echo 'Rename installer launcher'
    mv /usr/share/applications/liveinst.desktop /usr/share/applications/image-install.desktop

    echo 'Adjust installer launcher'
    installer_cmd="/usr/bin/xbiont image install"
    desktop-file-edit --set-key=Exec --set-value="$installer_cmd" /usr/share/applications/image-install.desktop
    desktop-file-edit --set-key=NoDisplay --set-value=false /usr/share/applications/image-install.desktop
    
    if [ -d /usr/share/cockpit/anaconda-webui ]; then
        echo 'Disable Anaconda WebUI'
        mv /usr/share/cockpit/anaconda-webui /usr/share/cockpit/anaconda-webui-disabled
    fi
}

if [ -f /etc/xdg/autostart/org.kde.discover.notifier.desktop ]; then
    echo 'Disable plasma-discover-notifier'
    desktop-file-edit --set-key=Hidden --set-value=true /etc/xdg/autostart/org.kde.discover.notifier.desktop
fi

if [ ! -f /usr/share/applications/image-install.desktop ]; then
    x::setup_installer_application
fi