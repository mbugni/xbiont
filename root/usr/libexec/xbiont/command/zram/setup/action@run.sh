#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# zram-setup/action@run: setup zram dynamically

x::log_info "Setting up zram..."

modprobe zram num_devices=1

zram_algorithm='lz4'
zram_resize_factor=1
zram_swappiness=80

# Calculate zram size
ram_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ram_total_bytes=$((ram_total_kb * 1024))
ram_one_gigabyte=$((1024 * 1024 * 1024))
echo "Total RAM detected: $ram_total_kb KB"

if [ $ram_total_bytes -gt $((16 * ram_one_gigabyte)) ]; then
    zram_resize_factor=4
elif [ $ram_total_bytes -gt $((8 * ram_one_gigabyte)) ]; then
    zram_resize_factor=2
else
    zram_resize_factor=1
fi

if [ "$(nproc)" -gt 4 ]; then
    zram_algorithm='zstd'
fi

zram_swappiness=$((zram_swappiness / zram_resize_factor))

if [ "$X_SYSTEM_LIFECYCLE" = 'live' ]; then
    zram_resize_factor=$((zram_resize_factor * 2))
    zram_algorithm='lz4'
fi

zram_size=$((ram_total_bytes / zram_resize_factor))

# Configure the /dev/zram0 device using zramctl
zramctl /dev/zram0 --size "$zram_size" --algorithm "$zram_algorithm"

# Initialize swap and activate it with maximum priority
mkswap /dev/zram0
swapon --priority 32767 /dev/zram0
sysctl vm.swappiness=$zram_swappiness

echo "/dev/zram0 activated (size: $(( $zram_size / 1024 / 1024 )) MB, algorithm: $zram_algorithm)"
echo "swappiness: $(cat /proc/sys/vm/swappiness)"
