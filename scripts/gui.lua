local const = require("lib.const")
local util = require("lib.util")

local gutil = require("scripts.gui.gutil")
local builder = require("scripts.gui.builder")
local components = require("scripts.gui.components")
local state = require("scripts.state")

local gui = {}

local get_logistic_groups_player = function(player)
    -- Controller: control.get_requester_point().sections
    local rp = player.get_requester_point()
    if not rp then
        return
    end
    return rp.sections
end

local get_logistic_groups_from_event = function(e)

    -- Get player
    local p = game.get_player(e.player_index)
    if not p then
        return
    end

    -- Get the correct logistic groups
    if e.gui_type == defines.gui_type.controller then
        return get_logistic_groups_player(p)
    elseif e.entity and e.entity.valid then
        return util.get_entity_logistic_groups(e.entity)
    end
end

-- gui.attach_on_open = function(e)
gui.build = function(player)
    if not player then
        return
    end
    -- Get player
    -- local p = game.get_player(e.player_index)
    -- if not p then
    --     return
    -- end

    -- Clear the state
    state.reset_player_gui_items(player)

    -- local gg = state.get_all_player_gui_items(player)

    -- Get the groups
    -- local groups = get_logistic_groups_from_event(e)
    local groups = util.get_opened_entity_logistic_sections(player)
    if not groups then
        return
    end

    -- Build
    if state.get_gui_is_maximized(player) then
        builder.build(player, groups)
    else
        builder.build_minimized(player)
    end

end

gui.repopulate = function(player)
    if not state.get_gui_is_maximized(player) then
        return
    end
    local main = gutil.get_main(player)
    if not main then
        return
    end
    components.repopulate(player)
end

gui.check_groups = function(player)
    if not state.get_gui_is_maximized(player) then
        return
    end
    -- Get all groups in the opened entity
    local groups = util.get_opened_entity_logistic_sections(player)
    if not groups then
        return
    end

    -- Get the groups GUI element
    local main = gutil.get_main(player)
    local lgrp = gutil.get_child(main, const.gui.groups)

    local regroup = false

    -- Check if group was added/removed
    if not lgrp or not lgrp.items or #groups ~= #lgrp.items then
        -- The number of groups do not match
        regroup = true
        goto continue
    end

    -- Check if group was renamed
    for i, g in ipairs(groups) do
        if (g.group ~= lgrp.items[i]) and
            not (g.group == "" and
                (lgrp.items[i] == const.gui.no_group or lgrp.items[i] == const.gui.circuit_controlled)) then
            regroup = true
            break
        end
    end

    ::continue::
    if regroup then
        components.regroup(player, groups)
    end
end

gui.close = function(player)
    builder.destroy(player)
end

------------------------------------------------------------------------------------------------
-- Event response
------------------------------------------------------------------------------------------------

gui.show_tab = function(player, tab_name)
    components.show_tab(player, tab_name)
end

gui.select_quality = function(player, quality)
    components.select_quality(player, quality)
end

gui.select_comparator = function(player, comparator)
    components.select_comparator(player, comparator)
end

-- Interfaces
gui.get_entity_selected_section = function(player)
    return gutil.get_entity_selected_section(player)
end

return gui
