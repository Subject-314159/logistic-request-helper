local const = require("lib.const")
local util = require("lib.util")
local state = require("scripts.state")

local gutil = {}

gutil.get_anchor = function(player)
    if util.get_player_setting_window_is_floating(player) then
        return player.gui.left
    else
        return player.gui.relative
    end
end

gutil.get_main = function(player)
    -- local anchor = gutil.get_anchor(player)
    -- if not anchor then
    --     return
    -- end
    -- return anchor[const.gui.main]

    -- Need to test if this works: It might be that the player changes a player setting while our GUI is opened
    -- We don't want double main GUIs
    return player.gui.relative[const.gui.main] or player.gui.left[const.gui.main]
end

local get_child_recursive
get_child_recursive = function(parent, target)
    if not parent then
        return
    end

    if parent.name == target then
        return parent
    else
        for _, child in pairs(parent.children) do
            -- Recursive search children if allowed, ie. does not have the no_recursion tag
            if not child.tags or (child.tags and not child.tags.no_recursion) or ignore_recursion then
                local res = get_child_recursive(child, target)
                if res then
                    return res
                end
            end
        end
    end
end
gutil.get_child = function(anchor, target)
    return get_child_recursive(anchor, target)
end

gutil.get_item_cell = function(anchor, target)
    -- This function returns the flow that contains the target item button
    if not anchor or (anchor.name ~= const.gui.tabscroll and anchor.name ~= const.gui.existingfl) then
        error("Invalid anchor")
    end

    for _, c1 in pairs(anchor.children) do -- Loop over the flows inside the scroll pane
        for _, c2 in pairs(c1.children) do -- Loop over the tables inside the flow
            for _, c3 in pairs(c2.children) do -- Loop over the cells (flows) inside the table
                if c3.name == target then
                    return c3
                end
            end
        end
    end
end

gutil.get_anchor_type = function(player)
    -- Easy checks
    if player.opened_gui_type == defines.gui_type.controller then
        -- Player inventory
        return defines.relative_gui_type.controller_gui
    elseif player.opened_gui_type ~= defines.gui_type.entity or not player.opened or not player.opened.valid then
        -- Not an entity or not valid
        return
    end

    local type = player.opened.type
    if player.opened.type == "entity-ghost" then
        type = player.opened.ghost_type
    end

    -- https://lua-api.factorio.com/latest/defines.html#defines.relative_gui_type
    local e = {
        ["car"] = defines.relative_gui_type.car_gui,
        ["cargo-landing-pad"] = defines.relative_gui_type.cargo_landing_pad_gui,
        ["constant-combinator"] = defines.relative_gui_type.constant_combinator_gui,
        ["logistic-container"] = defines.relative_gui_type.container_gui,
        ["roboport"] = defines.relative_gui_type.roboport_gui,
        ["spider-vehicle"] = defines.relative_gui_type.spider_vehicle_gui,
        ["space-platform-hub"] = defines.relative_gui_type.space_platform_hub_gui
    }
    if not e[type] and type ~= "rocket-silo" then
        game.print("[LRH] Error: " .. type .. " gui not found in definition list")
    end
    return e[type]
end

gutil.get_anchor_side = function(player)
end

gutil.get_entity_selected_section = function(player)
    -- Get all groups in the opened entity
    local groups = util.get_opened_entity_logistic_sections(player)
    if not groups then
        return
    end

    -- Get the selected group
    local main = gutil.get_main(player)
    if not main then
        return
    end
    local lb = gutil.get_child(main, const.gui.groups)
    local curg = lb.items[lb.selected_index]

    -- Loop through all the sections of this element to get the current selected section in our GUI
    local i = 1
    for _, s in pairs(groups) do
        if ((curg == const.gui.no_group or curg == const.gui.circuit_controlled) and i == lb.selected_index) or curg ==
            s.group then
            return s
        end
        i = i + 1
    end
end

gutil.player_opened_platform = function(player)
    return not (not script.active_mods["space-age"] or
               (gutil.get_anchor_type(player) ~= defines.relative_gui_type.space_platform_hub_gui))
end

return gutil
