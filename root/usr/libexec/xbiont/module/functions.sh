#!/usr/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (c) 2026 Massimiliano Bugni
#
# functions: common calls

function x::export_with_default() {
    local var_name=$1
    local default_value=$2

    # Check if the variable is not set or empty
    if [[ -z "${!var_name}" ]]; then
        # Use 'printf -v' to assign the value dynamically to the variable name
        printf -v "$var_name" "%s" "$default_value"
    fi

    export "$var_name"
}

function x::export_with_value() {
    local var_name=$1
    local value=$2

    printf -v "$var_name" "%s" "$value"
    export "$var_name"
}

function x::log_format() {
    local level_name=$1
    shift

    echo "[${level_name} $(date +'%Y-%m-%d %H:%M:%S')] $@"

    if [ "$level_name" = 'ERROR' ]; then
        echo "environment:"
        env | sed 's/^/· /'
        echo "stack:"
        for ((i=2; i<${#FUNCNAME[@]}; i++)); do
            echo "· ${FUNCNAME[$i]} (${BASH_SOURCE[$i]}:${BASH_LINENO[$((i-1))]})"
        done
    fi
}

function x::log_info() {
    x::log_format 'INFO' "$@"
}

function x::log_warn() {
    x::log_format 'WARN' "$@"
}

function x::log_error() {
    x::log_format 'ERROR' "$@"
}

function x::execute_activations() {
    for script in "$@"; do
        local script_path="${X_ACTIONABLE_DIR}/${script}"
        [ -x "$script_path" ] || continue

        # Execute the activation in a separate sub-shell
        (
            source "${X_CORE_DIR}/module/variables.sh"
            source "${X_CORE_DIR}/module/functions.sh"

            for module_script in "${X_ACTIONABLE_DIR}/module"/*.sh; do
                if [ -x "$module_script" ]; then
                    source "$module_script"
                fi
            done

            source "$script_path"
            local exit_code=$?
            if [ ${exit_code} -ne 0 ]; then
                x::log_warn "${script} exited with code ${exit_code}"
                exit $exit_code
            fi
        )
    done
}
