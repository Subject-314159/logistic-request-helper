local const = require('lib.const')
local util = {}

------------------------------------------------------------------------------------------------
-- Array
------------------------------------------------------------------------------------------------

util.array_has_value = function(array, value)
    for _, arr in pairs(array) do
        if arr == value then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------------------------------

-- Generic get setting value
util.get_player_setting = function(player_index, setting)
    return settings.get_player_settings(player_index)[setting].value
end

-- Get window position settings
util.get_player_window_setting = function(player_index)
    return util.get_player_setting(player_index, const.settings.window_position)
end
util.get_player_setting_window_is_floating = function(player_index)
    return util.get_player_window_setting(player_index) == const.settings.window_position_values.floating
end
util.get_player_setting_window_is_right = function(player_index)
    return util.get_player_window_setting(player_index) == const.settings.window_position_values.right
end
util.get_player_setting_window_is_left = function(player_index)
    return util.get_player_window_setting(player_index) == const.settings.window_position_values.left
end

-- Get group by settings
util.get_player_groupby_setting = function(player_index)
    return util.get_player_setting(player_index, const.settings.group_by)
end
util.get_player_setting_groupby_is_dropdown = function(player_index)
    return util.get_player_groupby_setting(player_index) == const.settings.group_by_values.dropdown
end
util.get_player_setting_groupby_is_tabs = function(player_index)
    return util.get_player_groupby_setting(player_index) == const.settings.group_by_values.tabs
end

------------------------------------------------------------------------------------------------
-- Global player
------------------------------------------------------------------------------------------------

util.get_global_player = function(player_index)
    if not global.players then
        global.players = {}
    end
    if not global.players[player_index] then
        global.players[player_index] = {}
    end
    return global.players[player_index]
end

return util
