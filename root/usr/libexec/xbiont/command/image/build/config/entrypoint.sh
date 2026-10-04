#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# entrypoint.sh: entry point for the image building container

if [ -z "$X_BUILD_COMMAND" ]; then
    if [ "$#" -gt 0 ]; then
        export X_BUILD_COMMAND="$@"
    else
        export X_BUILD_COMMAND='system-build'
    fi
fi

# Create loop devices if they don't exist
for i in $(seq 0 7); do
    if [ ! -b /dev/loop$i ]; then
        mknod /dev/loop$i b 7 $i
    fi
done

# Ensure the command is executed in this host(container) environment
export X_BUILD_RUNTIME='host'

# Use the template source to run the final command
exec ${X_BUILD_KIWING_DIR}/root/usr/bin/xbiont image build
