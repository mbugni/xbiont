#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/action@run: run the installer wizard

if [ -n "${X_INSTALL_REQUEST:-}" ]; then
    source "$X_ACTIONABLE_DIR/wizard@request.sh"
else
    export QT_API=pyqt6
    export X_INSTALL_EXECUTION=dryrun
    python3 "$X_ACTIONABLE_DIR/module/wizard_graphical.py"
fi
