#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-setup/action@run: configure live image after chroot build

[ -e /.profile ] || exit 0

export X_DISTRO_ID=$(source /etc/os-release && echo $ID)
export X_DISTRO_VERSION=$(source /etc/os-release && echo $VERSION_ID)
export X_PLYMOUTH_THEME="details"

source /.profile

export X_SYSTEM_HOSTNAME="${kiwi_iname:-xbiont}"
X_SYSTEM_HOSTNAME=${X_SYSTEM_HOSTNAME,,}

export X_SEAT_LOCALE="${kiwi_language}"
export X_SEAT_KEYTABLE="${kiwi_keytable}"
export X_SEAT_TIMEZONE="${kiwi_timezone}"
if [ "$X_SEAT_KEYTABLE" = 'us' ]; then
	export X_SEAT_KEYMODEL='pc104'
else
	export X_SEAT_KEYMODEL='pc105'
fi

case "$kiwi_profiles" in
	*"Workstation"*)
		export X_SEAT_PLATFORM='Workstation'
		;;
	*"Desktop"*)
		export X_SEAT_PLATFORM='Desktop'
		;;
	*)
		export X_SEAT_PLATFORM='Console'
		;;
esac

case "$kiwi_profiles" in
	*"Desktop-Plasma"*)
		export X_DESKTOP_CODENAME='plasma'
		X_PLYMOUTH_THEME="bgrt"
		;;
	*"Desktop-Trinity"*)
		export X_DESKTOP_CODENAME='trinity'
		;;
	*)
		x::log_warn "No desktop profile found in: $kiwi_profiles"
		;;
esac

x::execute_activations \
	"setup@system.sh" \
	"setup@network.sh" \
	"setup@seat.sh" \
	"desktop@${X_DESKTOP_CODENAME}.sh" \
	"repos@${X_DISTRO_ID}.sh" \
	"finalize@${X_DISTRO_ID}.sh"
