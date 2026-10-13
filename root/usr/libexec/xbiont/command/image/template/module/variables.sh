x::export_with_default 'X_TEMPLATE_TARGET_DIR' "$(pwd)/image/template"
x::export_with_default 'X_TEMPLATE_CONFIG_DIR' "$X_ACTIONABLE_DIR/config"
x::export_with_default 'X_IMAGE_VERSION'    "$(date +%y.%m.%d)"
