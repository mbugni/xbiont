#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/install@centos: run the image installer for CentOS

installer_path="/usr/bin/liveinst"
x::log_info "Running as privileged: $installer_path"
exec pkexec $installer_path
