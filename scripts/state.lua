local const = require("lib.const")
local env = require("scripts.state.env")

local state = {}

local settings = {
    group = "group",
    tab = "tab",
    planet = "planet",
    quality = "quality",
    comparator = "comparator",
    hover = "hover",
    action = "action",
    maximized = "maximized"
}

-- Generic getters/setters
local get_global_player = function(player)
    return storage.players[player.index]
end

local set_player_setting = function(player, setting, value)
    local gp = get_global_player(player)
    if not gp then
        return
    end
    gp[setting] = value
end
local get_player_setting = function(player, setting)
    local gp = get_global_player(player)
    if not gp then
        return
    end
    return gp[setting]
end

-- Specific getters/setters
state.set_player_group = function(player, group)
    set_player_setting(player, settings.group, group)
end

state.get_player_group = function(player)
    return get_player_setting(player, settings.group)
end

state.set_player_tab = function(player, tab)
    set_player_setting(player, settings.tab, tab)
end

state.get_player_tab = function(player)
    return get_player_setting(player, settings.tab)
end

state.set_player_comparator = function(player, comparator)
    set_player_setting(player, settings.comparator, comparator)
end
state.get_player_comparator = function(player)
    return get_player_setting(player, settings.comparator)
end

state.set_player_quality = function(player, quality)
    set_player_setting(player, settings.quality, quality)
end
state.get_player_quality = function(player)
    return get_player_setting(player, settings.quality)
end

state.set_player_planet = function(player, planet)
    set_player_setting(player, settings.planet, planet)
end
state.get_player_planet = function(player)
    return get_player_setting(player, settings.planet)
end

state.set_player_hover = function(player, name)
    set_player_setting(player, settings.hover, name)
end
state.get_player_hover = function(player)
    return get_player_setting(player, settings.hover)
end

state.set_player_action = function(player, action)
    set_player_setting(player, settings.action, action)
end
state.get_player_action = function(player)
    return get_player_setting(player, settings.action)
end

state.set_gui_maximized = function(player)
    set_player_setting(player, settings.maximized, true)
end
state.set_gui_minimized = function(player)
    set_player_setting(player, settings.maximized, false)
end
state.get_gui_is_maximized = function(player)
    return get_player_setting(player, settings.maximized)
end

-- Active GUI items
local get_global_gui = function(player)

end
local get_player_gui = function(player)
    local gp = get_global_player(player)
    if not gp["gui"] then
        gp["gui"] = {}
    end
    return gp["gui"]
end

state.set_player_gui_item = function(player, item)
    local gg = get_player_gui(player)
    gg[item] = true
end
state.get_player_gui_item = function(player, item)
    local gg = get_player_gui(player)
    return gg[item] ~= nil
end
state.get_all_player_gui_items = function(player)
    local gg = get_player_gui(player)
    return gg
end
state.reset_player_gui_items = function(player)
    local gg = get_player_gui(player)
    local r = {}
    for k, v in pairs(gg) do
        r[k] = v
    end
    for k, v in pairs(r) do
        gg[k] = nil
    end
end

-- Interfaces
state.get_base_quality = function()
    return env.get_base_quality()
end
state.get_all_quality = function()
    return env.get_all_quality()
end

state.get_groups = function()
    return env.get_groups()
end

-- Init
state.init_player = function(player)
    -- Ensure storage
    if not storage or not storage.players then
        state.init()
    end
    if not storage.players[player.index] then
        storage.players[player.index] = {}
    end

    -- Set defaults
    if not state.get_player_tab(player) then
        state.set_player_tab(player, const.gui.existing)
    end
    state.set_player_comparator(player, 2)
    state.set_player_quality(player, env.get_base_quality())
    state.set_player_planet(player, const.gui.planet_default)
    state.set_player_action(player, const.gui.actions.default)

    if state.get_gui_is_maximized(player) == nil then
        state.set_gui_maximized(player)
    end
end

state.init = function()
    -- Ensure storage
    storage = storage or {}
    storage.players = storage.players or {}

    -- Init environment
    env.init()

    -- Init each player
    for _, p in pairs(game.players) do
        state.init_player(p)
    end

end

return state
