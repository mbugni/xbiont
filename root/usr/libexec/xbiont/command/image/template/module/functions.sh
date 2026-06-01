#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# functions: common prepare functions

function x::install_file() {
    local src_file="$1"
    local dest_file="$2"
    local src_perm=$(stat -c %a "$src_file")
    local dest_dir=$(dirname "$dest_file")

    [ -d "$dest_dir" ] || mkdir -p "$dest_dir"
    install -m "$src_perm" "$src_file" "$dest_file"
}

function x::copy_and_resolve() {
    local src_file="$1"
    local dest_dir="$2"
    shift 2
    local vars="$*"

    if [ -d "$src_file" ]; then
        local src_files=($src_file/*)
        for src_item in "${src_files[@]}"; do
            if [ -d "$src_item" ]; then
                local dest_item="$dest_dir/$(basename "$src_item")"
                x::copy_and_resolve "$src_item" "$dest_item" "$vars"
            else
                x::copy_and_resolve "$src_item" "$dest_dir" "$vars"
            fi
        done
    else
        local dest_file="$dest_dir/$(basename "$src_file")"
        x::install_file "$src_file" "$dest_file"
        if [ -n "$vars" ]; then
            envsubst "$vars" < "$src_file" > "$dest_file"
        fi
        echo "$dest_file"
    fi
}
