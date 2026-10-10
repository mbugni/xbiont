#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/action@run: run the image installer

if [ -z "$X_INSTALL_EXECUTOR" ]; then
    case "$X_DISTRO_ID" in
    "fedora"|"centos")
        X_INSTALL_EXECUTOR="anaconda"
        ;;
    "debian")
        X_INSTALL_EXECUTOR="calamares"
        ;;
    *)
        x::log_error "Cannot determine installer for distro ID: $X_DISTRO_ID"
        exit 1
    esac
fi

x::execute_activations "installer@${X_INSTALL_EXECUTOR}.sh"
