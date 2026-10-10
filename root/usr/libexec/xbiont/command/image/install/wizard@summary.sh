#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@summary: show installation summary

inst_summary_msg="Main User: $X_INSTALL_FULL_NAME [$X_INSTALL_USERNAME]"
inst_summary_msg+="\nTarget Partition: $X_INSTALL_PARTITION_NAME"
inst_summary_msg+="\nBoot Mode: $X_INSTALL_BOOT_TYPE"
inst_summary_msg+="\n\nDo you want to proceed with the installation?"

dialog --stdout \
    --title " Installation Summary " \
    --yesno "$inst_summary_msg" 10 75 \
    </dev/tty
x::install_check_cancel
