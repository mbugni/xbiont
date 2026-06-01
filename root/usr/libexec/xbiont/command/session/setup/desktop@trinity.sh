#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# session-setup/desktop@trinity: desktop configuration for Trinity Desktop

konsole_shell_desktop="$HOME/.trinity/share/apps/konsole/shell.desktop"
    
[ -f "$konsole_shell_desktop" ] && exit 0

mkdir -p "$(dirname "$konsole_shell_desktop")"
cp /opt/trinity/share/apps/konsole/shell.desktop "$konsole_shell_desktop"

desktop-file-edit --set-key="Exec" --set-value="bash" "$konsole_shell_desktop"
desktop-file-edit --set-key="Term" --set-value="xterm-256color" "$konsole_shell_desktop"
desktop-file-edit --set-key="Schema" --set-value="Linux.schema" "$konsole_shell_desktop"
desktop-file-edit --remove-key="KeyTab" "$konsole_shell_desktop"
