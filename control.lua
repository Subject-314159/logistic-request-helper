local gui = require("scripts.gui")
local request = require("scripts.request")
local const = require("lib.const")
local util = require("lib.util")

local init = function()
    -- Force close our GUI on init or config changed
    for _, p in pairs(game.players) do
        gui.force_close(p.index)
    end
end

local add_commands = function()
    -- Add debug commands on init or load
    if not commands.commands["lrh_debug"] then
        commands.add_command("lrh_debug", "Run arrow library tests", function(command)
            local player = game.get_player(command.player_index)
            gui.toggle_debug_window(player, true)
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

script.on_configuration_changed(function(e)
    init()
end)

script.on_init(function(e)
    init()
    add_commands()
end)

script.on_load(function()
    add_commands()
end)

----------------------------------------------------------------------------------------------------
-- GUI toggle
----------------------------------------------------------------------------------------------------

local get_request_type_by_gui = function(player_index)
    local player = game.get_player(player_index)
    if not player then
        return
    end

    local type

    -- Check for character crafting window
    if player.opened_gui_type == defines.gui_type.controller then
        type = const.request_types.character
    elseif player.opened and player.opened_gui_type == defines.gui_type.entity then
        -- Check if opened window is of an allowed prototype
        local prot = game.entity_prototypes[player.opened.name]
        if util.array_has_value(const.allowed_prototypes, prot.type) then
            if util.array_has_value(const.allowed_vehicle_prototypes, prot.type) then
                type = const.request_types.vehicle
            elseif util.array_has_value(const.allowed_container_prototypes, prot.type) then
                if util.array_has_value(const.allowed_container_modes, prot.logistic_mode) then
                    type = const.request_types.container
                end
            end
        end
    end
    return type
end

local toggle_gui_shortcut = function(player_index)
    local player = game.get_player(player_index)
    if not player then
        return
    end

    -- If the GUI is to be opened topleft then open the gui, else open/close the character window
    if util.get_player_setting_window_is_floating(player_index) then
        -- Toggle the window
        gui.toggle_side(player_index)

        -- If the window is now open, update all requests
        if player.gui.left.lrh_gui then
            local request_type = get_request_type_by_gui(player_index) or const.request_types.character
            local target
            if not request_type or request_type == const.request_types.character then
                if not player.character then
                    -- Early exit if we do not have a character (i.e. god mode)
                    return
                end
                target = player
            else
                target = player.opened
            end
            local requests = request.get_all(request_type, target)
            gui.reset_indicators(player_index, requests, request_type)
        end
    else
        -- Open or close the window
        if player.opened or player.opened_gui_type == defines.gui_type.controller then
            player.opened = nil
        else
            player.opened = defines.gui_type.controller
        end
    end
end

script.on_event(defines.events.on_lua_shortcut, function(e)
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    if e.prototype_name == "lrh_shortcut" then
        toggle_gui_shortcut(e.player_index)
    end
end)

script.on_event("lrh_shortcut", function(e)
    toggle_gui_shortcut(e.player_index)
end)

-- script.on_event({defines.events.on_gui_opened, defines.events.on_gui_closed}, function(e)
script.on_event(defines.events.on_gui_opened, function(e)
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    local is_relative = not util.get_player_setting_window_is_floating(e.player_index)
    local request_type = get_request_type_by_gui(e.player_index)
    local target

    -- Check if our GUI is relative
    if is_relative then
        if request_type then
            -- Toggle if we have a request type
            gui.toggle_relative(e.player_index, request_type)
        else
            -- Force close if the target window doesn't match
            gui.force_close(e.player_index)
        end
    end

    -- Update request type and target according request type
    if not request_type then
        request_type = const.request_types.character
    end
    if request_type == const.request_types.character then
        if not player.character then
            -- Early exit if we do not have a character (i.e. god mode)
            gui.reset_indicators(player.index, nil, request_type)
            return
        end
        target = player
    else
        target = e.entity
    end

    -- Get & set requests
    local requests = request.get_all(request_type, target)
    gui.reset_indicators(e.player_index, requests, request_type)

end)

script.on_event(defines.events.on_gui_closed, function(e)
    -- If the closed GUI was not of an entity or controller we don't have to do anything
    local gui_types = {defines.gui_type.entity, defines.gui_type.controller}
    if not util.array_has_value(gui_types, e.gui_type) then
        return
    end
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    local is_relative = not util.get_player_setting_window_is_floating(e.player_index)

    -- Check if the player has the GUI open floating and the closed gui was of an allowed prototype
    local pgui = player.gui.left.lrh_gui
    local prot = e.entity and game.entity_prototypes[e.entity.name]
    local entity_is_allowed = util.array_has_value(const.allowed_prototypes, prot and prot.type)

    if is_relative then
        -- The GUI is anchored so we need to untoggle the shortcut button
        gui.toggle_relative(e.player_index)
    elseif pgui and entity_is_allowed then
        -- The GUI was showing the requests for that entity, we need to change it back to the character requests
        local req
        if player.character then
            -- Only get the request if we have a character, else request is to remain nil and clear all labels (e.g. god controller)
            req = request.get_all(const.request_types.character, player)
        end
        gui.reset_indicators(e.player_index, req, const.request_types.character)
    end
end)

----------------------------------------------------------------------------------------------------
-- Environmental events
----------------------------------------------------------------------------------------------------

script.on_event(defines.events.on_tick, function(e)
    -- Tick updates for logistic chests
    -- gui.tick_update()

    -- Only do tick updates if GUI position is attached and opened window is a chest
    for _, force in pairs(game.forces) do
        -- Only if the force has logistics unlocked
        if force.character_logistic_requests then
            -- Loop through players
            for _, player in pairs(force.players) do
                -- Check if the player has window attached to the side and has a window open
                local request_type = get_request_type_by_gui(player.index)
                if request_type == const.request_types.container then
                    gui.reset_indicators(player.index, request.get_all(request_type, player.opened), request_type)
                end

                -- Check if the GUI shows the label
                gui.hide_warning_label(player.index)
            end
        end
    end
end)

script.on_event(defines.events.on_gui_click, function(e)
    -- Get the player
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    local el = e.element

    -- Check for our button
    local name = el.name
    if name == "lrh_btn" or name == "lrh_min" or name == "lrh_max" then
        local btn = e.element
        local right = e.button == defines.mouse_button_type.right
        local request_type = get_request_type_by_gui(e.player_index)
        if not request_type or (request_type == const.request_types.character and not player.character) then
            -- Early exit if we do not have a character (i.e. god mode)
            return
        end
        request.on_button_clicked(player, btn, request_type, e.shift, e.control, e.alt, right)
    elseif name == "lrh_close_debug" then
        gui.toggle_debug_window(player, false)
    elseif el.tags and (el.tags.subtype == "expand-button" or el.tags.subtype == "tab-button") then
        gui.on_tab_expand_button_click(el, player)
    end

end)

local function process_slot_change(e, player)
    -- Get the request type and target
    local player_index = player.index
    local request_type = get_request_type_by_gui(player_index) or const.request_types.character
    local target
    if request_type == const.request_types.character then
        target = player
    else
        target = e.entity
    end
    -- Get the actual request
    local requests = request.get_all(request_type, target)

    -- Update the GUI with the new request
    if request.name then
        gui.set_indicator(player_index, requests[e.slot_index])
    else
        gui.reset_indicators(player_index, requests, request_type)
    end
end

script.on_event(defines.events.on_entity_logistic_slot_changed, function(e)

    -- Check if the entity is the player or something on the world
    local prot = game.entity_prototypes[e.entity.name]
    if util.array_has_value(const.allowed_prototypes, prot.type) then
        -- Update GUI for all players that have this entity open
        for _, player in pairs(game.players) do
            process_slot_change(e, player)
        end
    else
        local player = e.entity.player
        process_slot_change(e, player)
    end

end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
    -- Force close our GUI and the character screen if one of our mod settings changed
    if e.setting_type == "runtime-per-user" and string.sub(e.setting, 1, 4) == "lrh_" then
        gui.force_close(e.player_index)
    end
end)
