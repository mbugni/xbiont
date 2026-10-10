#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-install/wizard@install: run the image installer procedure


# Execution mode: dryrun or physical
x::export_with_default 'X_INSTALL_EXECUTION' "dryrun"

x::install_execute_dryrun() {
    local inst_percentage=10
    while test $inst_percentage != 100; do
        echo "XXX"
        echo "$inst_percentage"
        echo "Simulating installation - Progress: $inst_percentage%"
        echo "XXX"
        inst_percentage=`expr $inst_percentage + 10`
        sleep 0.1
    done
}

x::install_execute_physical() {

    exit 0 # Dry run for now

    # --- Partitioning ---
    echo "10" ; echo "XXX\n Initializing partitioning on $X_INSTALL_PARTITION_NAME... \nXXX"

    # --- Formatting and mounting ---
    echo "25" ; echo "XXX\n Formatting partitions... \nXXX"

    # --- Copying files (rsync) ---
    echo "45" ; echo "XXX\n Copying $X_DISTRO_ID SquashFS system to target disk... \nXXX"

    # --- Generating fstab ---
    echo "75" ; echo "XXX\n Generating fstab... \nXXX"
    
    # --- Main user configuration ---
    echo "80" ; echo "XXX\n Configuring user account... \nXXX"

    # --- Installing bootloader ---
    if [ "$X_INSTALL_BOOT_TYPE" != "NONE" ]; then
        echo "90" ; echo "XXX\n Installing GRUB bootloader... \nXXX"
    fi

    # --- Unmounting and finalizing ---
    echo "98" ; echo "XXX\n Unmounting and finalizing... \nXXX"

    echo "100" ; echo "XXX\n Done! \nXXX"
}

x::install_execute() {
    if [ "$X_INSTALL_EXECUTION" == "dryrun" ]; then
        x::install_execute_dryrun
    else
        x::install_execute_physical
    fi
}

# Visual installation progress
x::install_execute | dialog --stdout \
    --title " Installation in progress " \
    --gauge "\nInitialization..." 10 75 0
    < /dev/tty

if [ "$X_INSTALL_EXECUTION" == "physical" ]; then
    inst_succes_msg="\n$X_DISTRO_ID $X_DISTRO_VERSION has been installed successfully on $X_INSTALL_TARGET_DISK.\n\n"
    inst_succes_msg+="You can now reboot."

    dialog --stdout --title " Success! " \
        --msgbox "$inst_succes_msg" 10 75 \
        < /dev/tty
fi
