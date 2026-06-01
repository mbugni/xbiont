#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# session-setup/live@plasma: live session configuration for KDE Plasma

# Query xdg-user-dir directory because different languages
desktop_dir=$(xdg-user-dir DESKTOP)

# Check if installer is already configured
[ -e $desktop_dir/image-install.desktop ] && exit 0

echo "Add installer icon to $desktop_dir"
mkdir -p $desktop_dir
cp /usr/share/applications/image-install.desktop $desktop_dir/

# Make installer icon executable to disable KDE security warning
chmod +x $desktop_dir/image-install.desktop

# Default settings for liveuser
mkdir -p $HOME/.config

# Disable automount of 'known' devices
# https://bugzilla.redhat.com/show_bug.cgi?id=2073708
cat > $HOME/.config/kded_device_automounterrc << AUTOMOUNTER_EOF
[General]
AutomountEnabled=false
AutomountOnLogin=false
AutomountOnPlugin=false
AUTOMOUNTER_EOF
