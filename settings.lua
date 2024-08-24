data:extend({{
    type = "bool-setting",
    name = "lrh_attach-to-inventory",
    setting_type = "runtime-per-user",
    default_value = false,
    order = "a1"
}, {
    type = "string-setting",
    name = "lrh_attach-side",
    setting_type = "runtime-per-user",
    default_value = "left",
    allowed_values = {"left", "right"},
    order = "a2"
}, {
    type = "int-setting",
    name = "lrh_buttons-per-row",
    setting_type = "runtime-per-user",
    default_value = 10,
    minimum_value = 5,
    maximum_value = 20,
    order = "a3"
}, {
    type = "int-setting",
    name = "lrh_window-height",
    setting_type = "runtime-per-user",
    default_value = 656,
    minimum_value = 300,
    maximum_value = 1200,
    order = "a4"
}})
