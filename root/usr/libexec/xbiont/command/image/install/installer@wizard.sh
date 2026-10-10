#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/install@wizard: run the image installer wizard

# Check root privileges
#if [ "$(id -u)" -ne 0 ]; then
#    dialog --title " Fatal Error " --msgbox "\nThis installer requires root privileges." 7 50
#    clear ; exit 1
#fi

# Execution mode: dryrun or physical
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

if [ -f "/usr/bin/konsoleprofile" ]; then
    # Set terminal colors to Linux default, just like in a real console
    konsoleprofile colors=Linux
fi

# Select Target Partition ------------------------------------------------------

X_INSTALL_PARTITION_NAME=$(x::execute_activations "wizard@partition.sh")
x::install_clear_on_cancel

# Configure Bootloader ---------------------------------------------------------

X_INSTALL_BOOT_TYPE=$(x::execute_activations "wizard@boot.sh")
x::install_clear_on_cancel

# Configure Main User Account --------------------------------------------------

x::export_with_default 'X_INSTALL_FULL_NAME' ""
x::export_with_default 'X_INSTALL_USERNAME' ""
x::export_with_default 'X_INSTALL_PASSWORD' ""
x::export_with_default 'X_INSTALL_PASSWORD_CONFIRM' ""

X_INSTALL_USER_DATA=$(x::execute_activations "wizard@user.sh")
x::install_clear_on_cancel
x::install_parse_user_data "$X_INSTALL_USER_DATA"

# Confirm Installation Summary -------------------------------------------------

x::execute_activations "wizard@summary.sh"
x::install_clear_on_cancel

# Execute Installation ----------------------------------------------------------

x::execute_activations "wizard@install.sh"
clear
