#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/action@run: run the image installer

#export X_DISTRO_ID=$(source /etc/os-release && echo $ID)
export X_DISTRO_VERSION=$(source /etc/os-release && echo $VERSION_ID)

x::execute_activations "install@${X_DISTRO_ID}.sh"
