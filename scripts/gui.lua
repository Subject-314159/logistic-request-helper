local const = require('lib.const')
local util = require('lib.util')

local get_gui = function(player)
    local gui
    if not util.get_player_setting_window_is_floating(player.index) then
        -- if settings.get_player_settings(player.index)["lrh_attach-to-inventory"].value then
        gui = player.gui.relative.lrh_gui
    else
        gui = player.gui.left.lrh_gui
    end
    return gui
end

local get_global_player = function(player_index)
    if not global.players then
        global.players = {}
    end
    if not global.players[player_index] then
        global.players[player_index] = {}
    end
    return global.players[player_index]
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
            sg[order .. "_" .. ip.name] = ip.name
        end
    end
    return groups
end

local update_group_visibility = function(gui, player_index)

    local groups = get_groups()
    local gp = get_global_player(player_index)

    for group, subgroup in pairs(groups) do
        local g_fl = gui.inner[group]

        -- Set visibility of this group frame
        -- if group_by == "Drop down" then
        if util.get_player_setting_groupby_is_dropdown(player_index) then
            -- Initiate global player expand array
            if not gp.group_by_expand then
                gp.group_by_expand = {}
            end
            local gbe = gp.group_by_expand
            if gbe[group] == nil then
                gbe[group] = true
            end

            -- Set visibility according global player group by expand setting
            g_fl.content_frame.visible = gbe[group]

            -- Update sprite
            local btn = g_fl.group_header[group]
            if gbe[group] then
                btn.sprite = "utility/collapse"
                btn.hovered_sprite = "utility/collapse_dark"
            else
                g_fl.group_header[group].sprite = "utility/expand"
                btn.hovered_sprite = "utility/expand_dark"
            end
        else
            -- Initiate group by tab setting
            if not gp.group_by_tab then
                gp.group_by_tab = group
            end

            -- Set visibility according global player tab setting
            local active = gp.group_by_tab == group
            g_fl.visible = active
            if gui.tab_flow and gui.tab_flow[group] then
                gui.tab_flow[group].toggled = active
            end
        end
    end

end

local gui = {}

----------------------------------------------------------------------------------------------------
-- Build
----------------------------------------------------------------------------------------------------

local build = function(player, gui)
    -- Check if the player has logistic request enabled
    if not player.force.character_logistic_requests then
        -- Player does not have access to bots yet, display a default message
        local l = gui.add({
            type = "label",
            name = "label_logistics_not_available",
            caption = {const.gui.logistics_not_available}
        })
        gui.style.padding = 10
        return
    end

    -- Get global player
    local gp = get_global_player(player.index)

    -- 1. GET DATA
    local groups = get_groups()
    local group_by = util.get_player_groupby_setting(player.index)
    local nr_cols = util.get_player_setting(player.index, const.settings.buttons_per_row)

    -- 2. BUILD CONTENT

    -- inner
    local gui_inner
    if group_by == const.settings.group_by_values.dropdown then
        -- Inner scroll pane
        gui_inner = gui.add({
            type = "scroll-pane",
            name = "inner",
            direction = "vertical"
        })
        gui_inner.style.padding = 10
    else

        -- 'tab' flow
        local tflow = gui.add({
            type = "flow",
            direction = "horizontal",
            name = "tab_flow"
        })
        tflow.style.horizontally_stretchable = true
        tflow.style.bottom_margin = 15

        -- Inner flow
        gui_inner = gui.add({
            type = "flow",
            name = "inner",
            direction = "vertical"
        })
        gui_inner.style.horizontally_stretchable = true
    end

    -- Loop through data array
    for group, subgroups in pairs(groups) do
        -- The frame that will contain all items
        local g_fr

        -- Build the group by visualization
        -- Add group container
        local g_fl = gui_inner.add {
            type = "flow",
            name = group,
            direction = "vertical"
        }
        g_fl.style.horizontally_stretchable = true
        g_fl.style.bottom_padding = 10

        -- Add header above group frame
        if group_by == const.settings.group_by_values.dropdown then
            local hdr = g_fl.add {
                type = "flow",
                name = "group_header",
                direction = "horizontal"
            }
            hdr.style.vertical_align = "center"
            -- TODO: Implement functionality
            hdr.add {
                type = "sprite-button",
                name = group,
                tags = {
                    subtype = "expand-button"
                },
                sprite = "utility/collapse",
                hovered_sprite = "utility/collapse_dark",
                style = "control_settings_section_button"
            }
            local spr = hdr.add {
                type = "sprite",
                sprite = "item-group." .. group,
                resize_to_sprite = false
            }
            spr.style.width = 32
            spr.style.height = 32
            hdr.add {
                type = "label",
                caption = game.item_group_prototypes[group].localised_name
            }
        end

        -- Add a frame to contain all rows/buttons
        g_fr = g_fl.add({
            type = "frame",
            name = "content_frame",
            direction = "vertical",
            style = "inside_shallow_frame_with_padding"
        })
        g_fr.style.horizontally_stretchable = true

        -- Add the "tab" on top
        local tab_btn
        -- if group_by == "Tabs" then
        if group_by == const.settings.group_by_values.tabs then
            tab_btn = gui.tab_flow.add({
                type = "sprite-button",
                name = group,
                sprite = "item-group." .. group,
                tooltip = game.item_group_prototypes[group].localised_name,
                tags = {
                    subtype = "tab-button"
                }
            })
            tab_btn.style.size = 62
        end

        -- Process subgroups in group
        for subgroup, items in pairs(subgroups) do
            -- Add table for the buttons
            local sg_tbl = g_fr.add({
                type = "table",
                name = subgroup,
                column_count = nr_cols
            })

            -- Process items in subgroup
            local icnt = 0
            for order, name in pairs(items) do
                -- Add item button for each item
                -- Get min/max/name
                local lbl = {
                    name = name
                }
                local itm = game.item_prototypes[name]
                local tooltip = {"lrh.tooltip", itm.localised_name, itm.stack_size}

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
                    tags = lbl,
                    tooltip = tooltip
                })

                -- Add min label
                local lmin = bfl.add({
                    type = "label",
                    name = "lrh_min",
                    tags = lbl,
                    tooltip = tooltip,
                    caption = ""
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
                    tooltip = tooltip,
                    caption = ""
                })
                lmax.style.top_margin = -12
                lmax.style.right_margin = 3
                lmax.style.horizontal_align = "right"
                lmax.style.font = "item-count"
                lmax.style.maximal_width = 40

                icnt = icnt + 1
            end

            -- Add up to 10 column entries
            for i = icnt, nr_cols - 1, 1 do

                -- Add outer flow
                local bfl = sg_tbl.add {
                    type = "flow",
                    direction = "vertical"
                }
                bfl.style.width = 40
            end
        end
    end

    update_group_visibility(gui, player.index)

end

local get_default_gui_prop = function()
    -- The default prop for both floating and anchored gui
    return {
        type = "frame",
        name = "lrh_gui",
        direction = "vertical",
        caption = "Logistic request helper"
    }
end

local build_gui = function(player, prop, element)
    -- Make the gui
    local gui = player.gui[element].add(prop)

    -- Update the style
    gui.style.height = util.get_player_setting(player.index, const.settings.window_height)
    gui.style.vertically_stretchable = true

    -- Return the reference to the gui
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

local get_anchor = function(player, request_type)
    -- Get the side    
    local side
    if util.get_player_setting_window_is_left(player.index) then
        side = defines.relative_gui_position.left
    elseif util.get_player_setting_window_is_right(player.index) then
        side = defines.relative_gui_position.right
    end

    -- Set the anchor
    local anchor = {
        position = side
    }
    -- Attach it to the correct window
    if request_type == const.request_types.character then
        anchor.gui = defines.relative_gui_type.controller_gui
    elseif request_type == const.request_types.vehicle then
        anchor.gui = defines.relative_gui_type.spider_vehicle_gui
        -- Mod compatibility
        -- Spidertron patrols adds a GUI to the right, so we attach it to the left instead
        if game.active_mods["SpidertronPatrols"] then
            anchor.position = defines.relative_gui_position.left
        end
    elseif request_type == const.request_types.container then
        anchor.gui = defines.relative_gui_type.container_gui
    end
    return anchor
end

local build_gui_relative = function(player, request_type)
    -- Get default prop
    local prop = get_default_gui_prop()

    -- Add the anchor to the prop
    prop.anchor = get_anchor(player, request_type)

    -- Build the GUI
    return build_gui(player, prop, "relative")
end

local destroy_gui_relative = function(player)
    if player.gui.relative.lrh_gui then
        player.gui.relative.lrh_gui.destroy()
    end
end

----------------------------------------------------------------------------------------------------
-- Toggle
----------------------------------------------------------------------------------------------------

local untoggle_shortcut = function(player)
    player.set_shortcut_toggled("lrh_shortcut", false)
end

local toggle_shortcut = function(player)
    player.set_shortcut_toggled("lrh_shortcut", true)
end

gui.toggle_side = function(player_index)
    -- Get the player
    local player = game.get_player(player_index)
    if not player then
        return
    end

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

    -- If we did not early exit in above part we now end up with an emtpy frame, so we need to populate it
    build(player, gui)
end

gui.toggle_relative = function(player_index, request_type)
    -- Need to pass the request_type because we need to anchor our GUI to the correct windown
    -- Get the player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    if player.opened or player.opened_gui_type == defines.gui_type.controller then
        -- Toggle the shortcut
        toggle_shortcut(player)

        -- Check if our GUI is already built
        if player.gui.relative and player.gui.relative.lrh_gui then
            -- We need to re-anchor it
            player.gui.relative.lrh_gui.anchor = get_anchor(player, request_type)
            return
        else
            -- Attach the gui to the character screen for further processing and toggle the shortcut
            gui = build_gui_relative(player, request_type)
        end
    else
        -- The GUI was closed, we only need to untoggle the shortcut
        untoggle_shortcut(player)
        return
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

----------------------------------------------------------------------------------------------------
-- Update content
----------------------------------------------------------------------------------------------------

local update_flow_labels = function(flow, request)
    -- Get min/max
    local min
    local max
    if request then
        if request.count then
            max = request.count
        else
            min = request.min
            max = request.max
        end
        if min == max then
            min = nil
        end
    end

    -- Update button toggled
    local toggled = (max and max ~= "") or false

    -- Find and update child min/max labels
    for _, prop in pairs(flow.children) do
        if prop.name == "lrh_btn" then
            prop.toggled = toggled
        end
        if prop.name == "lrh_min" then
            prop.caption = parse(min)
        end
        if prop.name == "lrh_max" then
            prop.caption = parse(max)
        end
    end
end

gui.reset_indicators = function(player_index, requests, request_type)
    -- Get the player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    -- Get the player's gui
    local gui = get_gui(player)
    if not gui or not gui.inner then
        return
    end

    -- Update the frame title
    if request_type == const.request_types.character then
        gui.caption = {const.gui.window_title.default}
    elseif request_type == const.request_types.vehicle then
        gui.caption = {const.gui.window_title.vehicle}
    elseif request_type == const.request_types.container then
        gui.caption = {const.gui.window_title.container}
    end

    -- Loop through all elements and set all labels to blank
    for _, group in pairs(gui.inner.children) do
        for _, subgroup in pairs(group.content_frame.children) do
            for _, item in pairs(subgroup.children) do
                local itm = item.name
                local request
                if requests then
                    request = requests[itm]
                end
                update_flow_labels(item, request)
            end
        end
    end
end

gui.set_indicator = function(player_index, request)
    if not request.item then
        return
    end

    -- Get player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    -- Get GUI
    local gui = get_gui(player)
    if not gui then
        return
    end

    -- Get prototype & props
    local prot = game.item_prototypes[request.item]
    if not prot then
        return
    end
    local gr = prot.group or const.request.no_group
    local sgr = prot.subgroup or const.request.no_subgroup
    local ord = prot.order or const.request.no_order

    -- Get gui flow
    local fl = gui.inner[gr].content_frame[sgr][request.item]
    update_flow_labels(fl, request)
end

gui.on_tab_expand_button_click = function(button, player)
    -- Get variables
    local gui = get_gui(player)
    local gp = get_global_player(player.index)
    local group = button.name

    -- Update global player
    if util.get_player_setting_groupby_is_dropdown(player.index) then
        -- Initiate global player expand array
        if not gp.group_by_expand then
            gp.group_by_expand = {}
        end
        local gbe = gp.group_by_expand
        -- Check if group by expand exists
        if gbe[group] ~= nil then
            gbe[group] = not gbe[group]
        else
            -- Collapse the content (because it should be open by default)
            gbe[group] = false
        end
    else
        -- Update group by tab setting
        gp.group_by_tab = button.name
    end
    update_group_visibility(gui, player.index)
end

gui.hide_warning_label = function(player_index)
    local player = game.get_player(player_index)
    if not player then
        return
    end
    local gui = get_gui(player)
    if not gui then
        return
    end
    if gui.label_logistics_not_available then
        gui.label_logistics_not_available.destroy()
        build(player, gui)
    end
end

gui.init = function()
end

gui.toggle_debug_window = function(player, open)

    if player.gui.screen.lrh_debug then
        player.gui.screen.lrh_debug.destroy()
    end

    if not open then
        return
    end

    -- Make GUI
    local gui = player.gui.screen.add {
        type = "frame",
        name = "lrh_debug",
        caption = "Logistic Request Helper - Debug",
        direction = "vertical"
    }
    gui.style.horizontally_stretchable = true
    gui.style.vertically_stretchable = true
    gui.auto_center = true

    -- Make array
    local items = {}
    for _, ip in pairs(game.item_prototypes) do
        items[ip.name] = {
            group = ip.group.name or "n/a",
            subgroup = ip.subgroup.name or "n/a",
            order = ip.order or "n/a",
            flags = ip.flags or "n/a",
            type = ip.type or "n/a",
            stack_size = ip.stack_size or "n/a",
            valid = ip.valid or "n/a",
            has_flag_hidden = ip.has_flag("hidden")
        }
    end

    local entities = {}
    for _, ep in pairs(game.entity_prototypes) do
        entities[ep.name] = {
            flags = ep.flags or "n/a",
            placed_by = ep.items_to_place_this or "n/a",
            valid = ep.valid or "n/a"
        }
    end

    local requests = {}
    for i = 1, 65000, 1 do
        local slot = player.get_personal_logistic_slot(i)
        if slot.name then
            requests[i] = slot
        end
        i = i + 1
    end
    local data = {
        item_prototypes = items,
        entity_prototypes = entities,
        requests = requests,
        mods = game.active_mods
    }
    local txt = gui.add {
        type = "text-box",
        text = serpent.block(data)
    }
    txt.style.width = 600
    txt.style.height = 500

    -- Close button
    gui.add {
        type = "button",
        name = "lrh_close_debug",
        caption = "Close"
    }
    player.opened = gui
end

return gui
