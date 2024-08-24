data:extend({{
    type = "custom-input",
    name = "lrh_shortcut",
    key_sequence = "ALT + L",
    alternative_key_sequence = "SHIFT + E",
    action = "lua",
    order = "a"
}, {
    type = "shortcut",
    name = "lrh_shortcut",
    action = "lua",
    icon = {
        filename = "__base__/graphics/icons/logistic-robot.png",
        size = 64,
        mipmap_count = 2
    },
    toggleable = true
}})
