#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# zram-info/action@run: show zram info

echo "··· zramctl ···"
zramctl
echo "··· swapon ···"
swapon --show
