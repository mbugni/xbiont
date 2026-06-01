#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# session-setup/live@trinity: live session settings for Trinity Desktop

# Query xdg-user-dir directory because different languages
desktop_dir=$(xdg-user-dir DESKTOP)

# Check if installer is already configured
[ -e $desktop_dir/image-install.desktop ] && exit 0

echo "Add installer icon to $desktop_dir"
mkdir -p $desktop_dir
cp /usr/share/applications/image-install.desktop $desktop_dir/

# Make installer icon executable to disable TDE security warning
chmod +x $desktop_dir/image-install.desktop

# Default settings for liveuser
mkdir -p $HOME/.trinity/share/config

# Disable desktop media icons to avoid showing live media
cat > $HOME/.trinity/share/config/kdesktoprc << DESKTOP_EOF
[Media]
enabled=false
DESKTOP_EOF

# Disable new device popup during install
cat > $HOME/.trinity/share/config/mediamanagerrc << MEDIA_EOF
[Global]
AutostartEnabled=false
DeviceMonitorPopupsEnabled=false
NotificationPopupsEnabled=false
MEDIA_EOF
