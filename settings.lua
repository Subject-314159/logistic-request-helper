local const = require('lib.const')

local get_values = function(array)
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
    default_value = const.settings.window_position_values.right,
    allowed_values = get_values(const.settings.window_position_values),
    order = "a1"
}, {
    type = "bool-setting",
    name = const.settings.link_quality_control,
    setting_type = "runtime-per-user",
    default_value = false,
    order = "a2"
}})
