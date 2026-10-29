#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@post-installation: perform additional tasks after installation

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Finalizing the installation..."

# Configure plasma-setup to run once at first login and finalize the
# system setup (Phase 3: personal settings)
x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/etc/xbiont"
x::install_exec touch "$X_INSTALL_TARGET_ROOT/etc/xbiont/plasma-setup-once"

x::install_exec umount -R "$X_INSTALL_TARGET_ROOT"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Installation completed."
