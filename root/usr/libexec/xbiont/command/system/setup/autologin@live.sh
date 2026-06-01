#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# system-setup-autologin@live: ensure autologin for liveuser

function x::ensure_sddm_autologin() {
echo 'Ensure sddm autologin'
if [ -f /etc/sddm.conf ]; then
    sed -i 's/^#User=.*/User=liveuser/' /etc/sddm.conf
    sed -i "s/^#Session=.*/Session=plasma.desktop/" /etc/sddm.conf
else
cat > /etc/sddm.conf << SDDM_EOF
[Autologin]
User=liveuser
Session=plasma.desktop
SDDM_EOF
fi
}

function x::ensure_tdm_autologin() {
echo 'Ensure tdm autologin'
if [ -f /etc/trinity/tdm/tdmrc ]; then
    sed -i 's/^AllowNullPasswd=.*/AllowNullPasswd=true/' /etc/trinity/tdm/tdmrc
    sed -i 's/^#AutoLoginEnable=.*/AutoLoginEnable=true/' /etc/trinity/tdm/tdmrc
    sed -i 's/^#AutoLoginUser=.*/AutoLoginUser=liveuser/' /etc/trinity/tdm/tdmrc
else
cat > /etc/trinity/tdm/tdmrc << TDM_EOF
[X-*-Core]
AllowNullPasswd=true
AutoLoginEnable=true
AutoLoginUser=liveuser
TDM_EOF
fi
}

function x::ensure_getty_autologin() {
echo 'Ensure getty autologin'
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << GETTY_EOF
[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty --skip-login --autologin liveuser --noclear %I \$TERM
GETTY_EOF
/usr/bin/systemctl daemon-reload
}

display_manger_id="$(systemctl show --property=Id --value display-manager.service)"
echo "Detected display manager is: $display_manger_id"
case "$display_manger_id" in
    'sddm.service')
        x::ensure_sddm_autologin
    ;;
    'tdm.service')
        x::ensure_tdm_autologin
    ;;
    *)
        if [ ! -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
            x::ensure_getty_autologin
        fi
    ;;
esac
