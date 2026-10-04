x::export_with_default 'X_SEAT_PLATFORM'        'Workstation'
x::export_with_default 'X_SEAT_LOCALE'          'en_US'
x::export_with_default 'X_BUILD_TARGET_DIR'     "$(pwd)/image"
x::export_with_default 'X_BUILD_COMMAND'        'system-build'
x::export_with_default 'X_BUILD_RUNTIME'        'podman'
x::export_with_default 'X_BUILD_PROFILE'        "${X_SEAT_PLATFORM}-${X_SEAT_LOCALE}"
