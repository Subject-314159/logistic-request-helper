local const = require("lib.const")

local util = {}

------------------------------------------------------------------------------------------------
-- Array
------------------------------------------------------------------------------------------------

util.array_has_value = function(array, value)
    for k, v in pairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

------------------------------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------------------------------

-- Generic get setting value
local get_player_setting = function(player_index, setting)
    return settings.get_player_settings(player_index)[setting].value
end

-- Get window position settings
local get_player_window_setting = function(player_index)
    return get_player_setting(player_index, const.settings.window_position)
end
util.get_player_setting_window_is_floating = function(player_index)
    return get_player_window_setting(player_index) == const.settings.window_position_values.floating
end
util.get_player_setting_window_is_right = function(player_index)
    return get_player_window_setting(player_index) == const.settings.window_position_values.right
end
util.get_player_setting_window_is_left = function(player_index)
    return get_player_window_setting(player_index) == const.settings.window_position_values.left
end

-- Helper functions

util.get_entity_logistic_groups = function(entity)

    -- Check for logistic sections
    -- Do this one before logistic point because a roboport has both but only the sections has usable data
    local ls = entity.get_logistic_sections()
    if ls and ls.sections then
        return ls.sections
    end

    -- Constant combinators: entity.get_control_behavior().sections
    if entity.type == "constant-combinator" then
        local cb = entity.get_control_behavior()
        if cb and cb.sections ~= nil then
            return cb.sections
        end
    end

    -- Check for logistic point
    local lp = entity.get_logistic_point()
    if not (not lp or #lp == 0) then
        -- Normalize to single entry
        if type(lp) == "table" then
            lp = lp[1]
        end
        if lp.sections then
            return lp.sections
        end
    end
end

util.get_opened_entity = function(player)
    if player.opened_gui_type == defines.gui_type.controller then
        -- Player inventory is opened, return character
        return player.character
    elseif player.opened_gui_type ~= defines.gui_type.entity or not player.opened or not player.opened.valid then
        -- Not an entity or not valid
        return
    else
        return player.opened
    end
end

util.get_opened_entity_logistic_sections = function(player)
    local entity = util.get_opened_entity(player)
    if not entity then
        return
    end
    return util.get_entity_logistic_groups(entity)
end

util.has_quality = function()
    return not not script.active_mods["quality"]
end

local round = function(number)
    return math.floor(number + 0.5)
end
local numtostring = function(n)
    if math.floor(n) == n then
        return string.format("%.1f", n)
    else
        return tostring(n)
    end
end
util.parse = function(number, default)
    default = default or ""
    -- Ensure number
    if not number or number == nil then
        return default
    end
    number = tonumber(number)

    local parsed
    local lookup = {
        k = 1e3, -- kilo
        M = 1e6, -- mega
        G = 1e9, -- giga
        T = 1e12, -- tera
        P = 1e15, -- peta
        E = 1e18, -- exa
        Z = 1e21, -- zetta
        Y = 1e24 -- yotta
    }

    if number < lookup["k"] then
        return number
    elseif number > 4.2e9 then
        return "inf."
    end
    for prefix, multiplier in pairs(lookup) do
        if number >= multiplier then
            if (number / multiplier) < 10 then
                parsed = numtostring(round(number / multiplier * 10) / 10) .. prefix
            else
                parsed = numtostring(round(number / multiplier)) .. prefix
            end
        end
    end
    return parsed
end

local get_rocket_inventory_weight_limit = function()
    -- Probably needs to be updated for 2.1 as each rocket silo will get their individual lift weight
    return prototypes.utility_constants["default_rocket_lift_weight"]
end

util.get_rocket_capacity = function(item)
    if not item then
        return 0
    end
    local pi = prototypes.item[item]
    if not pi or not pi.weight then
        return 0
    end
    local wt = pi.weight

    local lim = get_rocket_inventory_weight_limit()
    if not lim then
        return 0
    end

    return (math.floor(lim / wt))

end

return util
