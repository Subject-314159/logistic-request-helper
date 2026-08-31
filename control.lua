local const = require("lib.const")
local util = require("lib.util")
local state = require("scripts.state")
local gui = require("scripts.gui")
local request = require("scripts.request")

local init = function()
    -- Force close all our GUIs to avoid conflicts
    for _, p in pairs(game.players) do
        gui.close(p)
    end

    -- Init each module
    state.init()
end

local load = function()
end

script.on_configuration_changed(function()
    init()
end)

script.on_init(function()
    init()
    load()
end)

script.on_load(function()
    load()
end)

script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game}, function(e)
    local p = game.get_player(e.player_index)
    state.init_player(p)
end)

script.on_event(defines.events.on_tick, function(e)
    -- TODO: Check each player if they have our GUI opened, if so go through the logistic groups and check if they still match with our GUI
    for _, p in pairs(game.players) do
        if not p.opened or not state.get_gui_is_maximized(p) then
            return
        end
        gui.check_groups(p)
    end
end)

script.on_event(defines.events.on_gui_opened, function(e)
    local p = game.get_player(e.player_index)
    -- gui.attach_on_open(e)
    gui.build(p)
end)
script.on_event(defines.events.on_gui_closed, function(e)
    local p = game.get_player(e.player_index)
    gui.close(p)
end)

script.on_event(defines.events.on_gui_hover, function(e)
    local p = game.get_player(e.player_index)
    local t = e.element.tags
    state.set_player_hover(p, t.signal)
end)
script.on_event(defines.events.on_gui_leave, function(e)
    local p = game.get_player(e.player_index)
    state.set_player_hover(p)
end)

script.on_event("lrh_increase_quality", function(e)
    local p = game.get_player(e.player_index)
    if not state.get_gui_is_maximized(p) then
        return
    end
    request.increase_quality(p, gui.get_entity_selected_section(p), state.get_player_hover(p))
end)
script.on_event("lrh_decrease_quality", function(e)
    local p = game.get_player(e.player_index)
    if not state.get_gui_is_maximized(p) then
        return
    end
    request.decrease_quality(p, gui.get_entity_selected_section(p), state.get_player_hover(p))
end)
script.on_event("lrh_increase_quality_linked", function(e)
    local p = game.get_player(e.player_index)
    if not state.get_gui_is_maximized(p) then
        return
    end
    if not p.mod_settings[const.settings.link_quality_control].value then
        return
    end
    request.increase_quality(p, gui.get_entity_selected_section(p), state.get_player_hover(p))
end)
script.on_event("lrh_decrease_quality_linked", function(e)
    local p = game.get_player(e.player_index)
    if not state.get_gui_is_maximized(p) then
        return
    end
    if not p.mod_settings[const.settings.link_quality_control].value then
        return
    end
    request.decrease_quality(p, gui.get_entity_selected_section(p), state.get_player_hover(p))
end)

script.on_event(defines.events.on_gui_click, function(e)
    -- Early exit if the gui element doesnt have our on_click tag
    if not e.element.tags or not e.element.tags[const.gui.tag] then
        return
    end

    local t = e.element.tags
    local h = t.handler
    local p = game.get_player(e.player_index)

    -- Handle action
    if h == const.gui.handler.tab_click then
        -- Change crafting tab
        state.set_player_tab(p, e.element.name)
        gui.show_tab(p, e.element.name)
    elseif h == const.gui.handler.item_click then
        -- Click item to change min/max
        request.handle(p, gui.get_entity_selected_section(p), t.signal, e.button, e.control, e.shift, e.alt)
    elseif h == const.gui.handler.planet_click then
        -- Change import from planet
        state.set_player_planet(p, t.planet)
        gui.repopulate(p)
    elseif h == const.gui.handler.quality_click then
        -- Change quality
        state.set_player_quality(p, e.element.name)
        gui.select_quality(p, e.element.name)
        gui.repopulate(p)
    elseif h == const.gui.handler.all_planet_click then
        -- Set import from planet for all requests
        request.set_planet(p, gui.get_entity_selected_section(p))
    elseif h == const.gui.handler.maximize_click then
        state.set_gui_maximized(p)
        gui.build(p)
    elseif h == const.gui.handler.minimize_click then
        state.set_gui_minimized(p)
        gui.build(p)
    end
end)
script.on_event(defines.events.on_gui_selection_state_changed, function(e)
    -- Early exit if the gui element doesnt have our on_click tag
    if not e.element.tags or not e.element.tags[const.gui.tag] then
        return
    end

    local t = e.element.tags
    local h = t.handler
    local p = game.get_player(e.player_index)

    if h == const.gui.handler.on_group_change then
        -- Change logistic group
        local itm = e.element.items[e.element.selected_index]
        if itm == const.gui.no_group then
            itm = nil
        end
        -- state.reset_player_gui_items(p)
        state.set_player_group(p, itm)
        gui.repopulate(p)
    elseif h == const.gui.handler.comparator_change then
        -- Change quality comparator
        state.set_player_comparator(p, e.element.selected_index)
        gui.select_comparator(p, e.element.selected_index)
        gui.repopulate(p)
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(e)
    -- Early exit if the gui element doesnt have our on_click tag
    if not e.element.tags or not e.element.tags[const.gui.tag] then
        return
    end

    local t = e.element.tags
    local h = t.handler
    local p = game.get_player(e.player_index)

    if h == const.gui.handler.on_action_change then
        -- Change click action radio button
        if util.array_has_value({const.gui.actions.stack_0_1, const.gui.actions.stack_1_2}, e.element.name) then
            state.set_player_comparator(p, 2)
        end
        state.set_player_action(p, e.element.name)
        gui.repopulate(p)
    end
end)

script.on_event(defines.events.on_entity_logistic_slot_changed, function(e)
    if storage.last_tick == game.tick then
        return
    end
    for _, p in pairs(game.players) do
        gui.repopulate(p)
    end
    storage.last_tick = game.tick
end)

-- Noteworthy locale
-- [gui-logistic]

-- [gui-train]
-- empty-train-group

-- Noteworthy functions
-- game.print(serpent.line(player.force.get_logistic_groups())) = all group names for that force
-- get_logistic_group(name).members = get the specific logistic sections
-- on_entity_logistic_slot_changed --> Also for player character?
