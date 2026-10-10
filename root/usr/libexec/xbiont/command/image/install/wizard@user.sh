#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@user: run the image installer user configuration

x::install_validate_user() {
    if [ -z "$X_INSTALL_FULL_NAME" ] || [ -z "$X_INSTALL_USERNAME" ]; then
        inst_user_msg="Name and username are required."
        return 1
    fi
    if [ -z "$X_INSTALL_PASSWORD" ] || [ -z "$X_INSTALL_PASSWORD_CONFIRM" ]; then
        inst_user_msg="Password and confirmation are required."
        return 1
    fi
    if [ "$X_INSTALL_PASSWORD" != "$X_INSTALL_PASSWORD_CONFIRM" ]; then
        inst_user_msg="Passwords do not match."
        return 1
    fi
    return 0
}

inst_user_msg="Configure the main user account for the new installation:"

while true; do
    X_INSTALL_USER_DATA=$(dialog --stdout \
        --title " Configure Main User " \
        --insecure \
        --mixedform "\n$inst_user_msg" 15 75 4 \
        "Your name:"        1 1 "$X_INSTALL_FULL_NAME" 1 20 40 40 0 \
        "Username:"         2 1 "$X_INSTALL_USERNAME" 2 20 40 40 0 \
        "Password:"         3 1 "$X_INSTALL_PASSWORD" 3 20 40 40 1 \
        "Confirm password:" 4 1 "$X_INSTALL_PASSWORD_CONFIRM" 4 20 40 40 1 \
        </dev/tty)
    x::install_check_cancel

    x::install_parse_user_data "$X_INSTALL_USER_DATA"
    x::install_validate_user && break
done

echo "$X_INSTALL_USER_DATA"
