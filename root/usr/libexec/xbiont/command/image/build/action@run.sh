#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/action@run.sh: execute the build command

case "$X_BUILD_RUNTIME" in
    podman)
        # Run the command in a podman container
        x::execute_activations "exec@podman-run.sh"
        ;;
    host)
        # Run the command on the current system
        if [ -x "${X_ACTIONABLE_DIR}/exec@${X_BUILD_COMMAND}.sh" ]; then
            x::execute_activations "exec@${X_BUILD_COMMAND}.sh"
        else
            exec "${X_BUILD_COMMAND}"
        fi
        ;;
    *)
        x::log_error "Unknown build runtime: $X_BUILD_RUNTIME"
        exit 1
        ;;
esac
