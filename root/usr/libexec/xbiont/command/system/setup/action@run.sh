#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-setup/action@run: prepare system for human usage

x::execute_activations \
    "machine@${X_MACHINE_MANUFACTURER}.sh" \
    "user@${X_SYSTEM_LIFECYCLE}.sh" \
    "autologin@${X_SYSTEM_LIFECYCLE}.sh" \
    "seat@${X_SYSTEM_LIFECYCLE}.sh"
