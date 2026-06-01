x::export_with_default 'X_TEMPLATE_TARGET_DIR' "$(pwd)/template"
x::export_with_default 'X_TEMPLATE_CONFIG_DIR' "$X_ACTIONABLE_DIR/config"
x::export_with_default 'X_IMAGE_VERSION'    "$(date +%Y.%m.%d)"
x::export_with_default 'X_IMAGE_NAME'       "xbiont-${X_DISTRO_ID}${X_DISTRO_VERSION}"
