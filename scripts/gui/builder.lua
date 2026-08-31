local const = require("lib.const")
local util = require("lib.util")

local gutil = require("scripts.gui.gutil")
local components = require("scripts.gui.components")

local builder = {}

---------------------------------------------------------------------------------------------------
--- Master structure
---------------------------------------------------------------------------------------------------

-- Top frame (settings)

local groups = {
    type = "flow",
    direction = "vertical",
    children = {{
        type = "flow",
        direction = "horizontal",
        children = {{
            type = "label",
            caption = "Groups"
        }}
    }, {
        type = "list-box",
        name = const.gui.groups,
        style = "list_box",
        tags = {
            [const.gui.tag] = true,
            handler = const.gui.handler.on_group_change
        }
    }}
}
local actions = {
    type = "flow",
    name = const.gui.actflow,
    direction = "vertical",
    children = {{
        type = "label",
        caption = "Click action"
    }}
}
local quality = {
    type = "flow",
    name = const.gui.qualflow,
    direction = "vertical",
    children = {{
        type = "line",
        direction = "horizontal"
    }, {
        type = "label",
        caption = "Quality"
    }, {
        type = "flow",
        direction = "horizontal",
        children = {{
            type = "drop-down",
            name = const.gui.comdrop,
            items = const.comparators,
            selected_index = 1,
            style = "train_schedule_circuit_condition_comparator_dropdown",
            tags = {
                [const.gui.tag] = true,
                handler = const.gui.handler.comparator_change
            }
        }, {
            type = "flow",
            name = const.gui.qualtbl,
            style = "packed_horizontal_flow"
        }}
    }}
}
local subright = {
    type = "flow",
    direction = "vertical",
    children = {{
        type = "flow",
        name = const.gui.expflow,
        direction = "horizontal",
        children = {{
            type = "line",
            name = const.gui.vdiv,
            direction = "vertical"
        }, {
            type = "flow",
            direction = "vertical",
            children = {actions, quality}
        }}
    }}
}

local planets = {
    type = "flow",
    name = const.gui.plntflow,
    direction = "vertical",
    children = {{
        type = "line",
        direction = "horizontal"
    }, {
        type = "flow",
        direction = "horizontal",
        children = {{
            type = "label",
            caption = "Import from"
        }, {
            type = "flow",
            direction = "horizontal"
        }, {
            type = "button",
            caption = "Set all",
            tags = {
                [const.gui.tag] = true,
                handler = const.gui.handler.all_planet_click
            }
        }}
    }, {
        type = "scroll-pane",
        horizontal_scroll_policy = "never",
        children = {{
            type = "table",
            name = const.gui.plnttbl,
            -- style = "packed_horizontal_flow"
            column_count = 9
        }}
    }}
}
local settings = {
    type = "frame",
    name = "top_frame",
    style = "lrh_top_frame",
    direction = "vertical",
    children = {{
        type = "flow",
        direction = "vertical",
        children = {{
            type = "flow",
            direction = "horizontal",
            children = {groups, subright}
        }, planets}
    }}
}

-- Bottom frame (tabs)
local tabs = {
    type = "frame",
    style = "lrh_bottom_frame",
    name = "bottom_frame",
    -- style = "inside_shallow_frame_with_padding",
    direction = "vertical",
    children = {{
        type = "flow",
        direction = "vertical",
        children = {{
            type = "table",
            column_count = 6,
            name = const.gui.tabtbl,
            children = {{
                type = "sprite-button",
                sprite = "lrh_request_big",
                name = const.gui.existing,
                tags = {
                    [const.gui.tag] = true,
                    handler = const.gui.handler.tab_click
                },
                tooltip = {"", "Existing requests in all groups"}
            }}
        }, {
            type = "scroll-pane",
            name = const.gui.tabscroll,
            -- style = "lrh_slot_scroll"
            style = "deep_slots_scroll_pane"
        }, {
            type = "scroll-pane",
            name = const.gui.existingfl,
            -- style = "lrh_slot_scroll"
            style = "deep_slots_scroll_pane",
            visible = false,
            children = {{
                type = "flow",
                children = {{
                    type = "table",
                    name = const.gui.existingtbl,
                    column_count = 10,
                    style = "filter_slot_table"
                }}
            }}
        }}
    }}
}

local header = {
    type = "flow",
    direction = "horizontal",
    children = {{
        type = "label",
        caption = "Logistic Request Helper",
        style = "frame_title"
    }, {
        type = "empty-widget",
        name = const.gui.dragger,
        direction = "horizontal",
        style = "draggable_space_header"
    }, {
        type = "sprite-button",
        sprite = "utility.import_slot",
        style = "frame_action_button",
        tags = {
            [const.gui.tag] = true,
            handler = const.gui.handler.minimize_click
        }
    }}
}

local structure = {
    type = "frame",
    name = const.gui.main,
    -- caption = "Logistic Request Helper",
    direction = "vertical",
    style = "lrh_main_frame",
    -- style = "frame_without_left_side",
    children = {header, settings, tabs}
}

local minimized = {
    type = "frame",
    name = const.gui.main,
    -- caption = "LRH",
    direction = "horizontal",
    -- style = "lrh_main_frame",
    -- style = "frame_without_left_side",
    children = {{
        type = "label",
        caption = "LRH",
        style = "frame_title"
    }, {
        type = "sprite-button",
        sprite = "utility.export_slot",
        style = "frame_action_button",
        tags = {
            [const.gui.tag] = true,
            handler = const.gui.handler.maximize_click
        }
    }}
}

---------------------------------------------------------------------------------------------------
--- Functions
---------------------------------------------------------------------------------------------------

local build_recursive
build_recursive = function(parent, structure)
    if not structure or not structure.type then
        game.print("[LRH] Error: Got empty structure, please open a bug report on the mod portal")
        return false
    end

    -- Build the properties array
    local prop = {}
    for k, v in pairs(structure) do
        if k ~= "children" then
            prop[k] = v
        end
    end

    -- Add the element
    local new = parent.add(prop)

    -- Recursive add elements
    for _, child in pairs(structure.children or {}) do
        if not build_recursive(new, child) then
            game.print("[LRH] Error while generating children of " .. structure.name ..
                           ", please open a bug report on the mod portal")
        end
    end

    -- Map tabs if any
    if structure.mapping then
        for _, map in pairs(structure.mapping) do
            new.add_tab(new[map[1]], new[map[2]])
        end
    end
    return true
end

builder.destroy = function(player)
    local main = gutil.get_main(player)
    if main then
        main.destroy()
    end
end

local anchor = function(player, main)
    -- Anchor the GUI
    if not util.get_player_setting_window_is_floating(player) then
        local anchor = {
            gui = gutil.get_anchor_type(player)
        }
        if not anchor.gui then
            return
        end
        if util.get_player_setting_window_is_right(player) then
            anchor.position = defines.relative_gui_position.right
        else
            anchor.position = defines.relative_gui_position.left
        end
        main.anchor = anchor
    end
end

builder.build = function(player, groups)
    -- Build the GUI
    builder.destroy(player)
    build_recursive(gutil.get_anchor(player), structure)
    local main = gutil.get_main(player)
    anchor(player, main)

    -- Hide expansion flows
    if not util.has_quality() then
        -- Disable the complete flow if quality is not enabled
        local fl = gutil.get_child(main, const.gui.expflow)
        fl.visible = false
    elseif not gutil.player_opened_platform(player) then
        -- Disable only the horizontal line and import from flow if space age is not enabled
        local fl = gutil.get_child(main, const.gui.plntflow)
        fl.visible = false
    end

    -- TODO make separate style
    -- main.style.height = 600
    main.style.vertically_stretchable = false
    local e
    e = gutil.get_child(main, "top_frame")
    e.style.minimal_height = 157
    e.style.maximal_height = 550
    e.style.vertically_stretchable = true

    e = gutil.get_child(main, "bottom_frame")
    -- e.style.vertically_stretchable = true

    e = gutil.get_child(main, const.gui.tabscroll)
    e.style.height = 400

    e = gutil.get_child(main, const.gui.existingfl)
    e.style.height = 400
    -- e.style.horizontally_stretchable = true
    -- e.style.vertically_stretchable = true

    e = gutil.get_child(main, const.gui.groups)
    e.style.vertically_stretchable = true

    e = gutil.get_child(main, const.gui.qualflow)
    e.style.horizontally_stretchable = false

    e = gutil.get_child(main, const.gui.plntflow)
    e.style.maximal_height = 250
    -- e.style.horizontally_stretchable = false

    e = gutil.get_child(main, const.gui.existing)
    e.style.size = 64

    e = gutil.get_child(main, const.gui.dragger)
    -- e.drag_target = main
    e.style.horizontally_stretchable = true
    e.style.height = 24

    components.populate(player, groups)
    return main
end

builder.build_minimized = function(player)
    -- Build the GUI
    builder.destroy(player)
    build_recursive(gutil.get_anchor(player), minimized)
    local main = gutil.get_main(player)
    anchor(player, main)
end

return builder
