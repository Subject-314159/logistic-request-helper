data:extend({{
    type = "bool-setting",
    name = "lrh_attach-to-inventory",
    setting_type = "runtime-global",
    default_value = false,
    order = "a1"
}, {
    type = "string-setting",
    name = "lrh_attach-side",
    setting_type = "runtime-global",
    default_value = "left",
    allowed_values = {"left", "right"},
    order = "a2"
}})
