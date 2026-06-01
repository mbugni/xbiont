#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# image-build/exec@system-build.sh: run the image build process using kiwi

function x::fix_legacy_bios_image() {
    xorriso -indev ${X_BUILD_TARGET_DIR}/${X_IMAGE_NAME}.ix86-${X_IMAGE_VERSION}.iso \
        -outdev ${X_BUILD_TARGET_DIR}/${X_IMAGE_NAME}.i386-pc-${X_IMAGE_VERSION}.iso \
        -publisher ${X_IMAGE_NAME} \
        -boot_image grub bin_path=boot/ix86/loader/eltorito.img \
        -boot_image grub grub2_mbr=/usr/lib/grub/i386-pc/boot_hybrid.img \
        -boot_image any grub2_boot_info=on -boot_image any boot_info_table=on \
        -boot_image any platform_id=0x00 -boot_image any emul_type=no_emulation \
        -joliet on -commit_eject all
}

$(x::kiwi_cmd) \
    --type=iso --debug --color-output \
    --profile="${X_BUILD_PROFILE}" \
    --shared-cache-dir="${X_BUILD_TARGET_DIR}/cache" \
    system build \
    --description="${X_BUILD_KIWING_DIR}" \
    --target-dir="${X_BUILD_TARGET_DIR}"

if [ "$X_IMAGE_PLATFORM" = 'i686' ]; then
    x::fix_legacy_bios_image
fi
