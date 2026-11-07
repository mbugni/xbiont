#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/install@post-installation: perform additional tasks after installation

x::export_with_default 'X_INSTALL_PERCENTAGE_MIN' "0"
x::export_with_default 'X_INSTALL_PERCENTAGE_MAX' "100"
x::export_with_default 'X_INSTALL_TARGET_ROOT' "/mnt/target"
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

x::install_progress $X_INSTALL_PERCENTAGE_MIN "Finalizing the installation..."

# Configure plasma-setup to run once at first login and finalize the
# system setup (Phase 3: personal settings)
x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/etc/xbiont"
x::install_exec touch "$X_INSTALL_TARGET_ROOT/etc/xbiont/plasma-setup-once"

# Keep the installation reachable for troubleshooting: run log and a
# journal excerpt are copied into the target
install_log_file="${X_ACTIONABLE_LOG_DIR:-/var/log/xbiont}/${X_ACTIONABLE_SERVICE:-run}-${X_ACTIONABLE_REQUEST:-installer}.log"
x::install_exec mkdir -p "$X_INSTALL_TARGET_ROOT/var/log/xbiont"
[ -f "$install_log_file" ] && \
    x::install_exec cp "$install_log_file" "$X_INSTALL_TARGET_ROOT/var/log/xbiont/"
x::install_exec sh -c "journalctl -b --no-pager > '$X_INSTALL_TARGET_ROOT/var/log/xbiont/journal.log'"

# Restore SELinux contexts on the copied filesystem
if command -v restorecon > /dev/null || [ "$X_INSTALL_EXECUTION" = dryrun ]; then
    for relabel_dir in boot dev etc root usr/lib usr/lib64 var/lib var/log; do
        x::install_exec restorecon -R "$X_INSTALL_TARGET_ROOT/$relabel_dir"
    done
fi

x::install_exec sync

# Unmount everything under the target in reverse mount order; on failure
# name the device that is still busy
unmount_points=$(
    if [ "$X_INSTALL_EXECUTION" = dryrun ]; then
        printf '%s\n' tmp run sys/fs/selinux sys/firmware/efi/efivars sys proc dev/shm dev/pts dev boot/efi ""
    else
        findmnt -rn -o TARGET -R "$X_INSTALL_TARGET_ROOT" 2>/dev/null | sed "s|^$X_INSTALL_TARGET_ROOT/*||" | sort -r
    fi
)
while read -r unmount_point; do
    mount_path="$X_INSTALL_TARGET_ROOT${unmount_point:+/$unmount_point}"
    if ! x::install_exec umount -lv "$mount_path"; then
        stuck_device=$(findmnt -nro SOURCE -T "$mount_path" 2>/dev/null | head -n1 || true)
        x::install_error unmount_failed "Unable to unmount $mount_path (device: ${stuck_device:-unknown})"
        exit 1
    fi
done <<< "$unmount_points"

x::install_progress $X_INSTALL_PERCENTAGE_MAX "Installation completed."
