#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# functions: common calls for image install command

x::install_check_cancel() {
    if [ $? -ne 0 ]; then
        dialog --stdout \
            --title " Cancelled " \
            --msgbox "\nInstallation cancelled. No changes made." 10 75 \
        </dev/tty
        exit 1
    fi
}

x::install_clear_on_cancel() {
    [ $? -ne 0 ] && clear && exit 0
}

x::install_parse_user_data() {
    read -rd '' \
        X_INSTALL_FULL_NAME \
        X_INSTALL_USERNAME \
        X_INSTALL_PASSWORD \
        X_INSTALL_PASSWORD_CONFIRM <<< "$1"
}