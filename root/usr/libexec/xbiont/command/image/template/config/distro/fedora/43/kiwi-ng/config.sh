#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# kiwi-ng/config.sh: kiwi-ng image configuration script

set -euxo pipefail

echo "Configure image: $kiwi_iname-$kiwi_iversion"
echo "Profiles: [$kiwi_profiles]"

# Setup live image
/usr/bin/xbiont image setup 

exit 0
