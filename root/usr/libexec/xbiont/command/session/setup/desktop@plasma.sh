#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# session-setup/desktop@plasma: session settings for KDE Plasma

if command -v flatpak &> /dev/null; then
    echo "Inject KDE Gtk settings into flatpak apps"
    flatpak override --user --filesystem=xdg-config/gtkrc:ro
    flatpak override --user --filesystem=xdg-config/gtkrc-2.0:ro
    flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
    flatpak override --user --filesystem=xdg-config/gtk-4.0:ro
fi
