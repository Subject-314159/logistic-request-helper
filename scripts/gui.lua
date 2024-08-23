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
    while empty_slots < 20 do
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

local gui = {}

gui.build = function(player_index)

    -- Get player
    local player = game.get_player(player_index)
    if not player then
        return
    end

    -- For now: destroy GUI (toggle)
    if player.gui.left.lrh_gui then
        player.set_shortcut_toggled("lrh_shortcut", true)
        player.gui.left.lrh_gui.destroy()
        return
    end

    -- Open the main frame
    player.set_shortcut_toggled("lrh_shortcut", false)
    local gui = player.gui.left.add({
        type = "frame",
        name = "lrh_gui",
        direction = "vertical",
        caption = "Logistic request helper"
    })
    gui.style.maximal_height = 600
    gui.style.horizontally_squashable = false
    gui.style.horizontally_stretchable = true
    -- gui.auto_center = true

    -- Check if the player has logistic request enabled
    if not player.force.character_logistic_requests then
        local l = gui.add({
            type = "label",
            caption = "Logistic requests are not yet available"
        })
        gui.style.padding = 10
        return
    end

    local gui_scroll = gui.add({
        type = "scroll-pane",
        direction = "vertical"
    })
    gui_scroll.style.padding = 10

    -- Build the content
    local requests = get_requests(player)

    -- Get group-subgroup-order array
    local groups = {}
    local groupnames = {}
    for _, ip in pairs(game.item_prototypes) do
        if not ip.has_flag("hidden") then
            local grp = ip.group.name or "No group"
            local sgrp = ip.subgroup.name or "No subgroup"
            local order = ip.order or "zzz"

            -- Store localised name
            groupnames[grp] = ip.group.localised_name

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

    -- Loop through array
    for group, subgroups in pairs(groups) do
        -- Add group container
        local g_fl = gui_scroll.add {
            type = "flow",
            direction = "vertical"
        }
        g_fl.style.horizontally_stretchable = true
        g_fl.style.bottom_padding = 10

        local hdr = g_fl.add {
            type = "flow",
            direction = "horizontal"
        }
        -- TODO: Implement functionality
        -- hdr.add {
        --     type = "sprite-button",
        --     name = "lrh_expand_group",
        --     sprite = "utility/collapse",
        --     hovered_sprite = "utility/collapse_dark",
        --     style = "control_settings_section_button"
        -- }
        hdr.add {
            type = "label",
            caption = groupnames[group]
        }
        local g_fr = g_fl.add({
            type = "frame",
            direction = "vertical",
            style = "inside_shallow_frame_with_padding"
        })
        g_fr.style.horizontally_stretchable = true

        -- Process subgroups in group
        for subgroup, items in pairs(subgroups) do
            -- Add table for the buttons
            local sg_tbl = g_fr.add({
                type = "table",
                column_count = 10
            })

            -- Process items in subgroup
            for order, name in pairs(items) do
                -- Add item button for each item
                local cnt
                local lbl = {
                    name = name
                }
                if requests[name] then
                    cnt = requests[name].min
                    lbl = requests[name]
                end
                -- local bfl = sg_fl.add {
                local bfl = sg_tbl.add {
                    type = "flow",
                    name = "sg_fl_" .. name
                }

                local btn = bfl.add({
                    type = "sprite-button",
                    name = "lrh_btn",
                    sprite = "item." .. name,
                    tags = lbl,
                    number = cnt
                })
                if cnt then
                    btn.toggled = true
                end
            end
        end
    end

end

gui.on_button_clicked = function(player, button, shift, control, alt, right)
    local btn = button
    local itm = game.item_prototypes[btn.tags.name]

    -- Get current count
    local requests = get_requests(player)
    local ireq = requests[btn.tags.name]
    local cnt

    -- Get slot index
    local i = get_empty_request_slot(player)

    -- Update if there is a request
    if ireq then
        cnt = ireq.min
        i = ireq.index
    end

    -- Add or subtract amount
    if right then
        -- Right mouse button to clear immediately, disregard any other controls
        cnt = -1
    elseif shift then
        if cnt then
            if cnt == 0 then
                cnt = -1
            else
                cnt = math.max(cnt - itm.stack_size, 0)
            end
        else
            cnt = 0
        end
    else
        -- TODO: control/alt click to increase/decrease min/max only
        cnt = (cnt or 0) + itm.stack_size
    end

    -- Set new logistic request amount
    if cnt == -1 then
        player.clear_personal_logistic_slot(i)
        btn.number = nil
        btn.toggled = false
    else
        local req = {
            name = btn.tags.name,
            min = cnt,
            max = cnt
        }
        player.set_personal_logistic_slot(i, req)

        -- Update button
        btn.number = cnt
        btn.toggled = true
    end
end

gui.toggle = function(player)
end

return gui
