#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# tool/installer/wizard@boot: run the installer boot configuration

mode=MBR
[ ! -d /sys/firmware/efi ] || mode=UEFI
jq -cn --arg default "$mode" '{version:1,type:"boot",default:$default,options:[{id:"UEFI",label:"UEFI — GRUB2 (recommended for modern systems)"},{id:"MBR",label:"Legacy MBR"},{id:"NONE",label:"No bootloader — managed externally"}]}'
