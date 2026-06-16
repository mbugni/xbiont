#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/install@fedora: run the image installer for Fedora

installer_path="/usr/bin/liveinst"
x::log_info "Running as privileged: $installer_path"
exec pkexec $installer_path --profile fedora
