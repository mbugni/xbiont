#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# kiwi-ng/post_bootstrap.sh: post bootstrap configuration for Debian 12

set -euxo pipefail

echo "Bootstrap image: $kiwi_iname-$kiwi_iversion"
echo "Profiles: [$kiwi_profiles]"

# Generate locales
echo "C.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
system_locale="${kiwi_language}.UTF-8"
if [ "$kiwi_language" != 'en_US' ]; then
    # Additional system-wide locale
	echo "${system_locale} UTF-8" >> /etc/locale.gen
fi
echo "LANG=${system_locale}" > /etc/default/locale
echo "Generating locales..."
locale-gen
locale -a

# Workaroud to address missing keymap for localectl systemd-firstboot. See:
#   https://groups.google.com/g/kiwi-images/c/5zHockGLFy8
if [ -f "/usr/share/keymaps/i386/qwerty/${kiwi_keytable}.kmap.gz" ]; then
    ln -s /usr/share/keymaps/i386/qwerty/${kiwi_keytable}.kmap.gz \
        /usr/share/keymaps/i386/qwerty/${kiwi_keytable}.map.gz
fi
