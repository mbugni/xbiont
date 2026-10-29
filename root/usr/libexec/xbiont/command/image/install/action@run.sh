#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/action@run: run the image installer

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

x::execute_activations "installer@${X_INSTALL_EXECUTOR}.sh"
