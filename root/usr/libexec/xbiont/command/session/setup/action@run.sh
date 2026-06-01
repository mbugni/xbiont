#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# session-setup/action@run: interactive session configuration

X_DESKTOP_CODENAME="${XDG_CURRENT_DESKTOP:-$XDG_SESSION_DESKTOP}"

case "$X_DESKTOP_CODENAME" in
    *TDE*|*Trinity*)
        echo "Environment: Trinity Desktop"
        export X_DESKTOP_CODENAME='trinity'
        export X_DESKTOP_VERSION='14_1'
        ;;
    *KDE*)
        echo "Environment: KDE Plasma"
        export X_DESKTOP_CODENAME='plasma'
        export X_DESKTOP_VERSION="$(plasmashell --version | cut -d' ' -f2 | cut -d'.' -f1)"
        ;;
    *)
        echo "Unknown desktop environment: '$X_DESKTOP_CODENAME'"
        ;;
esac

x::execute_activations \
    "desktop@${X_DESKTOP_CODENAME}.sh" \
    "${X_SYSTEM_LIFECYCLE}@${X_DESKTOP_CODENAME}.sh"
