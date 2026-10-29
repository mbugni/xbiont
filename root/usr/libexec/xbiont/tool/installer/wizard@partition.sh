#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@partition: run the image installer partition selection

# Get partition list, excluding:
# - zram devices
# - loop devices
# - boot partitions
# - currently mounted filesystems
x::install_targets
