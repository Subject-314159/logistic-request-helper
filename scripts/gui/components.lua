local const = require("lib.const")
local util = require("lib.util")

local state = require("scripts.state")
local gutil = require("scripts.gui.gutil")

local components = {}

local get_default_tooltip_header = function(item_name)
    -- Default header
    local iname = {"?", {"entity-name." .. item_name}, {"item-name." .. item_name}, item_name, "???"}
    local tltp = {"", "[font=heading-1]", iname, "[/font]\n"}
    local ip = prototypes.item[item_name]
    local ss
    if ip then
        ss = ip.stack_size or "?"
    else
        ss = "?"
    end
    table.insert(tltp, "[font=default-small]Stack size: " .. ss .. "[/font]\n")
    local rc = util.get_rocket_capacity(item_name)
    if rc ~= ss then
        table.insert(tltp, "[font=default-small]Rocket capacity: " .. rc .. "[/font]\n\n")
    else
        table.insert(tltp, "\n")
    end

    return tltp
end

local get_default_tooltip = function(player, item_name)
    local tltp = get_default_tooltip_header(item_name)
    table.insert(tltp, {"lrh-tooltip.default-shortcuts"})
    local linked = ""
    if player.mod_settings[const.settings.link_quality_control] then
        linked = "_linked"
    end
    local ciup = prototypes.custom_input["lrh_increase_quality"].key_sequence
    local cido = prototypes.custom_input["lrh_decrease_quality"].key_sequence
    table.insert(tltp, {"lrh-tooltip.quality-shortcuts", ciup, cido})
    return tltp
end

local populate_groups = function(main, player, groups)

    local lb = gutil.get_child(main, const.gui.groups)
    if not lb then
        return
    end
    lb.clear_items()

    local i = 1
    local prev = state.get_player_group(player)
    for _, g in pairs(groups) do

        -- Add the group to the listbox
        local grp = g.group
        if grp == "" then
            if not g.is_manual then
                grp = const.gui.circuit_controlled
            else
                grp = const.gui.no_group
            end
        end
        lb.add_item(grp)

        -- Check if this group is the previously selected one
        if grp == prev then
            -- Select this item
            lb.selected_index = i
        end
        i = i + 1
    end

    -- Select first item if nothing was remembered
    if lb.selected_index == 0 and #lb.items > 0 then
        lb.selected_index = 1
    end
end

local populate_actions = function(main, player)
    local flow = gutil.get_child(main, const.gui.actflow)
    local st = state.get_player_action(player)
    for k, v in pairs(const.gui.actions) do
        local prop = {
            type = "radiobutton",
            name = v,
            caption = {"lrh-click-action." .. v},
            state = (st == v),
            tags = {
                [const.gui.tag] = true,
                handler = const.gui.handler.on_action_change
            }
        }
        flow.add(prop)
    end
end
local select_action = function(player)
    local main = gutil.get_main(player)
    local flow = gutil.get_child(main, const.gui.actflow)
    local st = state.get_player_action(player)
    for k, v in pairs(const.gui.actions) do
        flow[v].state = (st == v)
    end
end

components.select_quality = function(player, quality)
    local main = gutil.get_main(player)
    if not main then
        return
    end
    local fl = gutil.get_child(main, const.gui.qualtbl)
    for _, c in pairs(fl.children) do
        if c.name == quality then
            c.toggled = true
        else
            c.toggled = false
        end
    end

    -- Update the dropdown
    local dd = gutil.get_child(main, const.gui.comdrop)
    if quality and state.get_player_comparator(player) == 1 then
        state.set_player_comparator(player, 2)
        dd.selected_index = 2
    end
end

components.select_comparator = function(player, comparator)
    local main = gutil.get_main(player)
    if not main then
        return
    end
    local dd = gutil.get_child(main, const.gui.comdrop)
    dd.selected_index = comparator or state.get_player_comparator(player)
    if comparator == 1 then
        state.set_player_quality(player)
        components.select_quality(player)
    end
end

local populate_quality = function(main, player)
    local cur = state.get_base_quality()
    local qual = state.get_all_quality()

    local fl = gutil.get_child(main, const.gui.qualtbl)
    local i = 1
    while true do
        -- Add the quality button
        local btn = fl.add({
            type = "sprite-button",
            name = cur,
            style = "tool_button",
            sprite = "quality/" .. cur,
            tags = {
                [const.gui.tag] = true,
                handler = const.gui.handler.quality_click
            }
        })

        -- Prepare next quality for next iteration
        if qual[cur].next then
            cur = qual[cur].next
        else
            break
        end
        i = i + 1
    end

    -- First set the comparator, then the quality
    components.select_comparator(player, state.get_player_comparator(player))
    components.select_quality(player, state.get_player_quality(player))
end

local populate_planets = function(main, player)
    local tbl = gutil.get_child(main, const.gui.plnttbl)

    tbl.add({
        type = "sprite-button",
        name = const.gui.planet_default,
        sprite = "virtual-signal.signal-question-mark",
        tags = {
            [const.gui.tag] = true,
            handler = const.gui.handler.planet_click,
            planet = const.gui.planet_default
        },
        tooltip = "Default prototype import planet"
    })
    for _, sl in pairs(prototypes.space_location) do
        if not sl.hidden then
            -- Get the icon
            local psp = {sl.type .. "." .. sl.name, "planet." .. sl.name, "space-location." .. sl.name,
                         "virtual-signal.signal-question-mark"}
            local sp
            for _, p in pairs(psp) do
                if helpers.is_valid_sprite_path(p) then
                    sp = p
                    break
                end
            end

            -- Add the button
            tbl.add({
                type = "sprite-button",
                name = sl.name,
                sprite = sp,
                tags = {
                    [const.gui.tag] = true,
                    handler = const.gui.handler.planet_click,
                    planet = sl.name
                },
                tooltip = {"space-location-name." .. sl.name}
            })
        end
    end
end

local populate_header = function(player, groups)
    local main = gutil.get_main(player)
    if not main then
        return
    end

    populate_groups(main, player, groups)
    populate_actions(main, player)
    populate_quality(main, player)
    populate_planets(main, player)
end

local populate_cell = function(player, table, item_name)
    if table[item_name] ~= nil then
        -- To make sure we do not add duplicate names (which should not occur in the first place)
        return
    end

    -- Add outer flow
    local bfo = table.add {
        type = "flow",
        name = item_name,
        direction = "vertical"
    }
    bfo.style.height = 40
    bfo.style.horizontal_align = "right"
    local bfl = bfo.add {
        type = "flow",
        name = "bfl",
        direction = "vertical"
    }
    local afl = bfo.add {
        type = "flow",
        name = "afl",
        direction = "vertical"
    }
    afl.style.horizontal_align = "right"

    -- Add button
    local tags = {
        [const.gui.tag] = true,
        handler = const.gui.handler.item_click,
        signal = item_name
    }
    local tooltip = get_default_tooltip(player, item_name)
    local btn = bfl.add({
        type = "sprite-button",
        name = "lrh_btn",
        sprite = "item." .. item_name,
        tags = tags,
        tooltip = tooltip,
        mouse_button_filter = {"left", "right", "middle"},
        style = "slot_button",
        raise_hover_events = true
    })

    -- Add quality label
    local lq = bfl.add({
        type = "label",
        name = "lrh_qual",
        tags = tags,
        tooltip = tooltip,
        caption = "",
        raise_hover_events = true
    })
    lq.style.top_margin = -22
    lq.style.left_margin = 2
    lq.style.font = "item-count"
    lq.style.maximal_width = 40

    -- Add max label
    local lmax = afl.add({
        type = "label",
        name = "lrh_max",
        tags = tags,
        tooltip = tooltip,
        caption = "",
        raise_hover_events = true
    })
    lmax.style.top_margin = -36
    lmax.style.right_margin = 3
    lmax.style.horizontal_align = "right"
    lmax.style.font = "item-count"
    lmax.style.maximal_width = 40

    -- Add min label
    local lmin = afl.add({
        type = "label",
        name = "lrh_min",
        tags = tags,
        tooltip = tooltip,
        caption = "",
        raise_hover_events = true
    })
    lmin.style.top_margin = -12
    lmin.style.right_margin = 3
    lmin.style.horizontal_align = "right"
    lmin.style.font = "item-count"
    lmin.style.maximal_width = 40

    return bfl

end

local populate_tabs = function(player)
    local main = gutil.get_main(player)
    if not main then
        return
    end

    local tabs = gutil.get_child(main, const.gui.tabtbl)
    local tbl = gutil.get_child(tabs, const.gui.tabtbl)
    local frm = gutil.get_child(main, const.gui.tabscroll)

    local groups = state.get_groups()
    local seltab, selpane
    -- local prev = state.get_player_tab(player)
    -- if prev == const.gui.existing then
    --     seltab = gutil.get_child(main, const.gui.existing)
    --     selpane = gutil.get_child(main, const.gui.existingfl)
    -- end
    for _, grp in pairs(groups) do

        -- Create the tab
        local tab = tbl.add({
            type = "sprite-button",
            sprite = "item-group." .. grp.name,
            name = grp.name,
            tags = {
                [const.gui.tag] = true,
                handler = const.gui.handler.tab_click
            }
        })
        tab.style.size = 64

        -- Create the pane
        local pane = frm.add({
            type = "flow",
            direction = "vertical",
            name = grp.name,
            tags = {
                ["no_recursion"] = true
            }
        })
        pane.visible = false

        -- Populate the pane
        for _, subgrp in pairs(grp.subgroups) do
            local tbl = pane.add({
                type = "table",
                -- name = subgrp.name, -- Note to self: If we need this in the future, we need to check for name == quality as it conflicts with a GUI property
                column_count = 10,
                style = "filter_slot_table"
            })
            tbl.style.bottom_margin = -4
            local i = 0
            for _, itm in pairs(subgrp.items) do
                local fl = populate_cell(player, tbl, itm)
                i = i + 1
            end
        end

        -- Remember the tab and pane if it is the first one, or if it is the previously selected tab
        -- if not seltab or grp.name == prev then
        --     seltab = tab
        --     selpane = pane
        -- end
    end

    -- Select the correct tab
    components.show_tab(player, state.get_player_tab(player))
end

local get_quality_label = function(quality, operator, force_fill)
    local q = ""
    if operator then
        if operator ~= "=" then
            q = q .. operator
        elseif force_fill then
            q = q .. "   "
        end
    end
    if quality then
        if quality ~= state.get_base_quality() or operator ~= "=" or
            (quality == state.get_base_quality() and force_fill) then
            q = q .. "[font=technology-slot-level-font][quality=" .. quality .. "][/font]"
        end
    else
        q = "[font=technology-slot-level-font][virtual-signal=signal-any-quality][/font]"
    end
    return q
end

local select_planet = function(player)
    local pl = state.get_player_planet(player)
    local main = gutil.get_main(player)
    local tbl = gutil.get_child(main, const.gui.plnttbl)
    if not tbl then
        return
    end
    for _, c in pairs(tbl.children) do
        if c.name == pl then
            c.toggled = true
        else
            c.toggled = false
        end
    end
end

local set_amount = function(player, flow, filter)
    -- Check if we got a flow, it could be that we end up here from a constant combinator with a signal which is not an item, thus we will not get a flow
    if not flow then
        return
    end
    local min_lbl = flow["afl"]["lrh_min"]
    local max_lbl = flow["afl"]["lrh_max"]
    local q_lbl = flow["bfl"]["lrh_qual"]
    local btn = flow["bfl"]["lrh_btn"]
    if not min_lbl or not max_lbl or not q_lbl or not btn then
        error("Unable to find one of the components")
    end

    -- Remember this item
    state.set_player_gui_item(player, flow.name)

    -- If we did not receive a filter then we need to reset the button
    if not filter or not filter.value then
        min_lbl.caption = ""
        max_lbl.caption = ""
        q_lbl.caption = ""
        btn.style = "slot_button"
        return
    end

    local name, min, max, quality, operator = filter.value.name, filter.min, filter.max, filter.value.quality,
        filter.value.comparator

    -- If we do not match the filter quality then we need to mark the button and leave the labels as is
    local q, com = state.get_player_quality(player), state.get_player_comparator(player)
    local match_cq = (filter.value.quality == q) and
                         (filter.value.comparator == const.comparators[com] or
                             (not filter.value.comparator and com == 1))
    if not match_cq then
        btn.style = "red_slot_button"
        return
    end

    if min_lbl then
        min_lbl.caption = util.parse(min) or ""
    end
    if max_lbl then
        local default = ""
        if min then
            default = "inf."
        end
        max_lbl.caption = util.parse(max, default)
    end

    -- Quality
    if not q_lbl then
        return
    end
    if not min and not max then
        q_lbl.caption = ""
        return
    end

    q_lbl.caption = get_quality_label(quality, operator)

    -- Set style/selected
    flow["bfl"]["lrh_btn"].toggled = true
end

local set_tooltip = function(flow, tooltip)
    local min_lbl = flow["afl"]["lrh_min"]
    local max_lbl = flow["afl"]["lrh_max"]
    local q_lbl = flow["bfl"]["lrh_qual"]
    local btn = flow["bfl"]["lrh_btn"]
    if not min_lbl or not max_lbl or not q_lbl or not btn then
        error("Unable to find one of the components")
    end

    local tltp = get_default_tooltip_header(flow.name)

    -- Existing requests
    local txt = ""
    for _, filter in pairs(tooltip or {}) do
        txt = txt .. get_quality_label(filter.value.quality, filter.value.comparator, true) .. "  "
        txt = txt .. (filter.min or "0") .. " - " .. (filter.max or "inf.") .. "\n"
    end
    if txt ~= "" then
        table.insert(tltp, "[font=default-bold]Existing requests[/font]\n" .. txt .. "\n")
    end

    -- Default shortcuts
    table.insert(tltp, {"lrh-tooltip.default-shortcuts"})

    -- Set the tooltip
    for _, comp in pairs({min_lbl, max_lbl, q_lbl, btn}) do
        comp.tooltip = tltp
    end
end
local set_tooltips = function(player, anchor, tt)
    local gg = state.get_all_player_gui_items(player)
    for _, c1 in pairs(anchor.children) do -- Loop over the flows inside the scroll pane
        for _, c2 in pairs(c1.children) do -- Loop over the tables inside the flow
            for _, c3 in pairs(c2.children) do -- Loop over the cells (flows) inside the table
                if gg[c3.name] then
                    set_tooltip(c3, tt[c3.name])
                end
            end
        end
    end
end

local repopulate_existing = function(player)
    -- Plug gutil
    local sections = util.get_opened_entity_logistic_sections(player)
    local main = gutil.get_main(player)
    local existbl = gutil.get_child(main, const.gui.existingtbl)
    local gg = state.get_all_player_gui_items(player)

    -- Clear existing table
    existbl.clear()
    local items = {}

    -- Collect all items from all groups
    for _, s in pairs(sections or {}) do
        for _, f in pairs(s.filters or {}) do
            if f.value and prototypes.item[f.value.name] then
                items[f.value.name] = true
            end
        end
    end

    -- Collect the items from previously existing
    for item, _ in pairs(gg or {}) do
        items[item] = true
    end

    -- Make the button in the existing table for all items that we encountered
    for item, _ in pairs(items) do
        populate_cell(player, existbl, item)
    end
end

local set_amounts = function(player)
    -- Plug gutil
    local cur = gutil.get_entity_selected_section(player)
    local main = gutil.get_main(player)
    local anchor = gutil.get_child(main, const.gui.tabscroll)
    local existfl = gutil.get_child(main, const.gui.existingfl)

    -- Repopulate the existing tab
    repopulate_existing(player)

    -- Go through all items in our GUI and set the appropriate amount
    if cur then
        -- Set each amount as filtered
        local tt = {}
        for _, f in pairs(cur.filters or {}) do
            -- TODO: Change the style if there is a filter entry but it does not match the quality/operator/planet
            if f.value then -- Check for value because empty slots will have a filter entry
                -- Update both buttons
                for _, a in pairs({anchor, existfl}) do
                    local fl = gutil.get_item_cell(a, f.value.name)
                    if fl then
                        set_amount(player, fl, f)
                    end
                end
                if not tt[f.value.name] then
                    tt[f.value.name] = {}
                end
                table.insert(tt[f.value.name], f)
            end
        end
        for _, a in pairs({anchor, existfl}) do
            set_tooltips(player, a, tt)
        end
    else
        -- This occurs if there are no groups, we need to think about what to do now
        -- game.print("[LRH] This is not implemented yet")
    end
end

local reset_amounts = function(player)
    local groups = state.get_groups()
    local main = gutil.get_main(player)
    local anchor = gutil.get_child(main, const.gui.tabscroll)
    local gg = state.get_all_player_gui_items(player)
    for _, c1 in pairs(anchor.children) do -- Loop over the flows inside the scroll pane
        for _, c2 in pairs(c1.children) do -- Loop over the tables inside the flow
            for _, c3 in pairs(c2.children) do -- Loop over the cells (flows) inside the table
                if gg[c3.name] then
                    set_amount(player, c3) -- Reset the amount
                    local btn = c3["bfl"]["lrh_btn"]
                    btn.toggled = false
                    btn.style = "slot_button"
                end
            end
        end
    end
end

components.populate = function(player, groups)
    populate_header(player, groups)
    populate_tabs(player)
    select_planet(player)
    set_amounts(player)
end

components.repopulate = function(player)
    select_planet(player)
    components.select_comparator(player, state.get_player_comparator(player))
    select_action(player)
    reset_amounts(player)
    set_amounts(player)
end

components.regroup = function(player, groups)
    local main = gutil.get_main(player)
    populate_groups(main, player, groups)
end

components.show_tab = function(player, tab_name)
    local main = gutil.get_main(player)

    local tbl = gutil.get_child(main, const.gui.tabtbl)
    for _, tab in pairs(tbl.children or {}) do
        if tab.name == tab_name then
            tab.toggled = true
        else
            tab.toggled = false
        end
    end

    local frm = gutil.get_child(main, const.gui.tabscroll)
    local ext = gutil.get_child(main, const.gui.existingfl)
    if tab_name == const.gui.existing then
        frm.visible = false
        ext.visible = true
    else
        frm.visible = true
        ext.visible = false
    end
    for _, tab in pairs(frm.children or {}) do
        if tab.name == tab_name then
            tab.visible = true
        else
            tab.visible = false
        end
    end

end
return components
