local const = require('lib.const')

local function get_values(array)
    local res = {}
    for k, v in pairs(array) do
        table.insert(res, v)
    end
    return res
end

data:extend({{
    type = "string-setting",
    name = const.settings.window_position,
    setting_type = "runtime-per-user",
    default_value = const.settings.window_position_values.floating,
    allowed_values = get_values(const.settings.window_position_values),
    order = "a1"
}, {
    type = "string-setting",
    name = const.settings.group_by,
    setting_type = "runtime-per-user",
    default_value = const.settings.group_by_values.dropdown,
    allowed_values = get_values(const.settings.group_by_values),
    order = "a2"
}, {
    type = "int-setting",
    name = const.settings.window_height,
    setting_type = "runtime-per-user",
    default_value = const.settings.window_height_values.default,
    minimum_value = const.settings.window_height_values.min,
    maximum_value = const.settings.window_height_values.max,
    order = "a4"
}, {
    type = "int-setting",
    name = const.settings.buttons_per_row,
    setting_type = "runtime-per-user",
    default_value = const.settings.buttons_per_row_values.default,
    minimum_value = const.settings.buttons_per_row_values.min,
    maximum_value = const.settings.buttons_per_row_values.max,
    order = "a3"
}})
