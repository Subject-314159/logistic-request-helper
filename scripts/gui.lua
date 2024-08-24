local get_empty_request_slot = function(player)

    local i = 1
    while i < 65545 do
        local slot = player.get_personal_logistic_slot(i)
        if not slot.name then
            return i
        end
        i = i + 1
    end
end

local get_requests = function(player)

    local requests = {}
    local i = 1
    local empty_slots = 0
    while empty_slots < 40 do
        local slot = player.get_personal_logistic_slot(i)
        if slot.name then
            empty_slots = 0
            requests[slot.name] = slot
            requests[slot.name].index = i
        else
            empty_slots = empty_slots + 1
        end
        i = i + 1
    end

    return requests
end

local round = function(number)
    return math.floor(number + 0.5)
end

local parse = function(number)
    if not number or number == nil then
        return ""
    end
    local parsed
    local lookup = {
        K = 1e3, -- kilo
        M = 1e6, -- mega
        G = 1e9, -- giga
        T = 1e12, -- tera
        P = 1e15, -- peta
        E = 1e18, -- exa
        Z = 1e21, -- zetta
        Y = 1e24 -- yotta
    }

    if number < lookup["K"] then
        return number
    elseif number > 4.2e9 then
        return "inf."
    end
    for prefix, multiplier in pairs(lookup) do
        if number >= multiplier then
            if (number / multiplier) < 10 then
                parsed = tostring(round(number / multiplier * 10) / 10) .. prefix
            else
                parsed = tostring(round(number / multiplier)) .. prefix
            end
        end
    end
    return parsed
end

local get_request_parsed = function(requests, name)
    -- local min = ""
    -- local max = ""
    local min, max
    if requests[name] then
        min = requests[name].min
        max = requests[name].max

        -- TODO: Change to prefix & infity
    end

    return parse(min), parse(max)
end

local get_groups = function()
    -- Generate group-subgroup-order array
    local groups = {}
    for _, ip in pairs(game.item_prototypes) do
        if not ip.has_flag("hidden") then
            local grp = ip.group.name or "No group"
            local sgrp = ip.subgroup.name or "No subgroup"
            local order = ip.order or "zzz"

            -- Add/get group
            if not groups[grp] then
                groups[grp] = {}
            end
            local g = groups[grp]

            -- Add/get subgroup
            if not g[sgrp] then
                g[sgrp] = {}
            end
            local sg = g[sgrp]

            -- Add item + order
            sg[order] = ip.name
        end
    end
    return groups
end

local gui = {}

----------------------------------------------------------------------------------------------------
-- Button click handlers
----------------------------------------------------------------------------------------------------

gui.on_button_clicked = function(player, button, shift, control, alt, right)
    local btn = button
    local itm = game.item_prototypes[btn.tags.name]
    local min, max

    -- Get current count
    local requests = get_requests(player)
    local ireq = requests[btn.tags.name]

    -- Get slot index
    local i = get_empty_request_slot(player)

    -- Update if there is a request
    if ireq then
        min = ireq.min
        max = ireq.max
        i = ireq.index
    end

    -- Add or subtract amount
    if right then
        -- Right mouse button to clear immediately, disregard any other controls
        max = -1
    elseif shift then
        if max then
            if max == 0 then
                max = -1
            else
                max = math.max(max - itm.stack_size, 0)
                min = math.max(min - itm.stack_size, 0)
            end
        else
            min = 0
            max = 0
        end
    else
        -- TODO: control/alt click to increase/decrease min/max only
        min = (min or 0) + itm.stack_size
        max = (max or 0) + itm.stack_size
    end

    -- Set new logistic request amount
    if max == -1 then
        player.clear_personal_logistic_slot(i)
    else
        local req = {
            name = btn.tags.name,
            min = min,
            max = max
        }
        player.set_personal_logistic_slot(i, req)
    end
end

----------------------------------------------------------------------------------------------------
-- Update
----------------------------------------------------------------------------------------------------

local update_gui = function(player, gui)

    -- Check if the player has logistic request enabled
    if not player.force.character_logistic_requests then
        return
    end
    -- Remove info label if still present
    if gui.label_logistics_not_available then
        gui.label_logistics_not_available.destroy()
    end

    -- Get request and group info
    local requests = get_requests(player)
    local groups = get_groups()

    -- Loop over frame elements and update info
    for group, subgroups in pairs(groups) do
        for subgroup, items in pairs(subgroups) do
            for item, prop in pairs(items) do
                local flow = gui.scroll[group].content_frame[subgroup][prop]
                local min, max = get_request_parsed(requests, prop)
                if min == max then
                    flow.lrh_min.caption = ""
                else
                    flow.lrh_min.caption = min
                end
                flow.lrh_max.caption = max
                if max and max ~= "" then
                    flow.lrh_btn.toggled = true
                else
                    flow.lrh_btn.toggled = false
                end
            end
        end
    end
end
----------------------------------------------------------------------------------------------------
-- Build/destroy
----------------------------------------------------------------------------------------------------

local build = function(player, gui)
    -- Check if the player has logistic request enabled
    if not player.force.character_logistic_requests then
        -- Player does not have access to bots yet, display a default message
        local l = gui.add({
            type = "label",
            name = "label_logistics_not_available",
            caption = "Logistic requests are not yet available"
        })
        gui.style.padding = 10
        return
    end

    -- 1. GET DATA
    -- Get current logistic requests of player
    local requests = get_requests(player)
    local groups = get_groups()

    -- 2. BUILD CONTENT
    -- Add a scroll pane
    local gui_scroll = gui.add({
        type = "scroll-pane",
        name = "scroll",
        direction = "vertical"
    })
    gui_scroll.style.padding = 10

    -- Loop through data array
    for group, subgroups in pairs(groups) do
        -- Add group container
        local g_fl = gui_scroll.add {
            type = "flow",
            name = group,
            direction = "vertical"
        }
        g_fl.style.horizontally_stretchable = true
        g_fl.style.bottom_padding = 10

        -- Add header
        local hdr = g_fl.add {
            type = "flow",
            name = "group_header",
            direction = "horizontal"
        }
        -- TODO: Implement functionality
        -- hdr.add {
        --     type = "sprite-button",
        --     name = "expand_button",
        --     sprite = "utility/collapse",
        --     hovered_sprite = "utility/collapse_dark",
        --     style = "control_settings_section_button"
        -- }
        hdr.add {
            type = "label",
            caption = game.item_group_prototypes[group].localised_name
        }
        -- Add a frame to contain all subgroups
        local g_fr = g_fl.add({
            type = "frame",
            name = "content_frame",
            direction = "vertical",
            style = "inside_shallow_frame_with_padding"
        })
        g_fr.style.horizontally_stretchable = true

        -- Process subgroups in group
        for subgroup, items in pairs(subgroups) do
            -- Add table for the buttons
            local sg_tbl = g_fr.add({
                type = "table",
                name = subgroup,
                column_count = settings.get_player_settings(player.index)["lrh_buttons-per-row"].value
            })

            -- Process items in subgroup
            for order, name in pairs(items) do
                -- Add item button for each item
                -- Get min/max/name
                local min, max = get_request_parsed(requests, name)
                local lbl = {
                    name = name
                }

                -- Add outer flow
                local bfl = sg_tbl.add {
                    type = "flow",
                    name = name,
                    direction = "vertical"
                }
                bfl.style.horizontally_stretchable = false
                bfl.style.horizontal_align = "right"
                bfl.style.height = 48

                -- Add button
                local btn = bfl.add({
                    type = "sprite-button",
                    name = "lrh_btn",
                    sprite = "item." .. name,
                    tags = lbl
                    -- number = max
                })
                if max then
                    btn.toggled = true
                end

                -- Add min label
                local lmin = bfl.add({
                    type = "label",
                    name = "lrh_min",
                    tags = lbl,
                    caption = min
                })
                lmin.style.top_margin = -36
                lmin.style.right_margin = 3
                lmin.style.horizontal_align = "right"
                lmin.style.font = "item-count"
                lmin.style.maximal_width = 40

                -- Add max label
                local lmax = bfl.add({
                    type = "label",
                    name = "lrh_max",
                    tags = lbl,
                    caption = max
                })
                lmax.style.top_margin = -12
                lmax.style.right_margin = 3
                lmax.style.horizontal_align = "right"
                lmax.style.font = "item-count"
                lmax.style.maximal_width = 40
            end
        end
    end

end

local get_default_gui_prop = function()
    return {
        type = "frame",
        name = "lrh_gui",
        direction = "vertical",
        caption = "Logistic request helper"
    }
end

local build_gui = function(player, prop, element)
    local gui = player.gui[element].add(prop)
    gui.style.height = settings.get_player_settings(player.index)["lrh_window-height"].value
    -- gui.style.vertically_squashable = false
    gui.style.vertically_stretchable = true
    return gui
end

local build_gui_side = function(player)
    local prop = get_default_gui_prop()
    return build_gui(player, prop, "left")
end

local destroy_gui_side = function(player)
    if player.gui.left.lrh_gui then
        player.gui.left.lrh_gui.destroy()
        return
    end
end

local build_gui_relative = function(player)
    local prop = get_default_gui_prop()
    local anchor = {
        gui = defines.relative_gui_type.controller_gui,
        position = defines.relative_gui_position[settings.get_player_settings(player.index)["lrh_attach-side"].value]
    }
    prop.anchor = anchor
    return build_gui(player, prop, "relative")
end

local destroy_gui_relative = function(player)
    if player.gui.relative.lrh_gui then
        player.gui.relative.lrh_gui.destroy()
    end
end

----------------------------------------------------------------------------------------------------
-- Toggle stuff
----------------------------------------------------------------------------------------------------

local untoggle_shortcut = function(player)
    player.set_shortcut_toggled("lrh_shortcut", false)
end

local toggle_shortcut = function(player)
    player.set_shortcut_toggled("lrh_shortcut", true)
end

gui.toggle = function(player_index, raised_by_script)
    -- Get the player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    local gui

    -- First check if the toggle was caused by shortcut script or by opening/closing the character screen
    if raised_by_script then
        -- Check where the GUI should be positioned depending on global setting
        if settings.get_player_settings(player.index)["lrh_attach-to-inventory"].value then
            -- Destroy any remaining side GUI
            destroy_gui_side(player)

            -- Check if the character screen was open or closed
            if player.opened_gui_type == defines.gui_type.controller then
                -- The character screen was open, so we need to close it and untoggle the shortcut
                player.opened = nil
                untoggle_shortcut(player)
                return
            else
                -- The character screen was closed, so we need to open it
                player.opened = defines.gui_type.controller
                toggle_shortcut(player)

                -- Check if our GUI is already anchored to the crafting screen
                if player.gui.relative.lrh_gui then
                    -- No need to do anything
                    return
                else
                    -- Attach the gui to the character gui
                    gui = build_gui_relative(player)
                end
            end
        else
            -- Destroy any remaining anchored GUI
            destroy_gui_relative(player)

            -- Check if the side GUI was open or not
            if player.gui.left.lrh_gui then
                -- Close the GUI and early exit
                destroy_gui_side(player)
                untoggle_shortcut(player)
                return
            else
                -- Build the GUI
                gui = build_gui_side(player)
                toggle_shortcut(player)
            end
        end
    else
        -- Check where the GUI should be positioned depending on global setting
        if settings.get_player_settings(player.index)["lrh_attach-to-inventory"].value then
            -- Destroy any remaining side GUI
            destroy_gui_side(player)

            -- The trigger was caused by opening/closing the character crafting screen
            if player.opened_gui_type == defines.gui_type.controller then
                -- The screen was just opened
                -- Check if our GUI is already anchored
                if player.gui.relative.lrh_gui then
                    -- No need to do anything, only toggle the shortcut
                    toggle_shortcut(player)
                    return
                else
                    -- Attach the gui to the character screen for further processing and toggle the shortcut
                    gui = build_gui_relative(player)
                    toggle_shortcut(player)
                end
            else
                -- The GUI was closed, we only need to untoggle the shortcut
                untoggle_shortcut(player)
                return
            end
        else
            -- Destroy any remaining anchored GUI
            destroy_gui_relative(player)
            return
        end
    end

    -- If we did not early exit in above part we now end up with an emtpy frame, so we need to populate it
    build(player, gui)
end

gui.force_close = function(player_index)
    -- Get the player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    -- Untoggle and close all our GUI
    untoggle_shortcut(player)
    destroy_gui_relative(player)
    destroy_gui_side(player)

    -- Close player GUI
    if player.opened_gui_type == defines.gui_type.controller then
        player.opened = nil
    end
end

gui.tick_update = function()
    for _, force in pairs(game.forces) do
        -- Only if the force has logistics unlocked
        if force.character_logistic_requests then
            -- Loop through players
            for _, player in pairs(force.players) do
                -- Get GUI based on their settings
                local gui
                if settings.get_player_settings(player.index)["lrh_attach-to-inventory"].value then
                    gui = player.gui.relative.lrh_gui
                else
                    gui = player.gui.left.lrh_gui
                end

                -- Update GUI if opened
                if gui then
                    update_gui(player, gui)
                end
            end
        end
    end
end

gui.init = function()
end

return gui
