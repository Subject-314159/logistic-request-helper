-- Magic numbers
local outer_gui_height = 500
local outer_gui_width = 445
local top_frame_height = 300

---------------------------------------------------------------------------------------------------
--- Main skeleton components
---------------------------------------------------------------------------------------------------
-- Flows
-- data.raw["gui-style"].default["lrh_horizontal_flow"] = {
--     type = "horizontal_flow_style"
--     -- horizontally_stretchable = "on"
--     -- vertically_stretchable = "on"
-- }
-- data.raw["gui-style"].default["lrh_main_flow"] = {
--     type = "horizontal_flow_style",
--     horizontally_stretchable = "on",
--     horizontal_spacing = 12
--     -- vertically_stretchable = "on"
-- }

-- data.raw["gui-style"].default["lrh_horizontal_flow_right"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     horizontal_align = "right",
--     horizontally_stretchable = "on",
--     vertical_align = "center"
-- }

-- data.raw["gui-style"].default["lrh_horizontal_flow_spaced"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     horizontal_spacing = 12
-- }
-- data.raw["gui-style"].default["lrh_horizontal_flow_nospacing"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     horizontal_spacing = 0
-- }

-- data.raw["gui-style"].default["lrh_horizontal_flow_padded"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     left_padding = 4,
--     right_padding = 4
-- }
-- data.raw["gui-style"].default["lrh_horizontal_flow_centered"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     horizontally_stretchable = "on",
--     vertical_align = "center"
-- }
-- data.raw["gui-style"].default["lrh_horizontal_flow_queue_status"] = {
--     type = "horizontal_flow_style",
--     parent = "lrh_horizontal_flow",
--     horizontally_stretchable = "on",
--     vertically_stretchable = "on",
--     horizontal_align = "center",
--     vertical_align = "center"
-- }

-- data.raw["gui-style"].default["lrh_vertical_flow"] = {
--     type = "vertical_flow_style",
--     -- vertically_stretchable = "on"
--     horizontally_stretchable = "on"
-- }
-- data.raw["gui-style"].default["lrh_vertical_flow_spaced"] = {
--     type = "vertical_flow_style",
--     parent = "lrh_vertical_flow",
--     vertical_spacing = 12
-- }
-- data.raw["gui-style"].default["lrh_vertical_flow_nospacing"] = {
--     type = "vertical_flow_style",
--     parent = "lrh_vertical_flow",
--     vertical_spacing = 0
-- }
-- data.raw["gui-style"].default["lrh_vflow_leftpadded"] = {
--     type = "vertical_flow_style",
--     parent = "lrh_vertical_flow",
--     left_padding = 18
-- }

-- Top level frame
data.raw["gui-style"].default["lrh_main_flow"] = {
    type = "vertical_flow_style",
    -- vertically_stretchable = "stretch_and_expand"
    vertically_stretchable = "on"
}
data.raw["gui-style"].default["lrh_main_frame"] = {
    type = "frame_style",
    parent = "frame_without_left_side",
    vertically_stretchable = "stretch_and_expand",
    vertical_flow_style = data.raw["gui-style"].default["lrh_main_flow"],
    width = outer_gui_width,
    natural_height = outer_gui_height
}
data.raw["gui-style"].default["lrh_top_frame"] = {
    type = "frame_style",
    parent = "frame",
    horizontally_stretchable = "on",
    height = top_frame_height
}
data.raw["gui-style"].default["lrh_bottom_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    horizontally_stretchable = "on",
    vertically_stretchable = "stretch_and_expand"
    -- height = outer_gui_height
}

data.raw["gui-style"].default["lrh_inside_deep_frame"] = {
    type = "frame_style",
    parent = "inside_deep_frame",
    horizontally_stretchable = "on",
    vertically_stretchable = "on"
}

-- Sub section frames
data.raw["gui-style"].default["lrh_shallow_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame",
    padding = 10
}
data.raw["gui-style"].default["lrh_horizontal_shallow_frame"] = {
    type = "frame_style",
    parent = "lrh_shallow_frame",
    horizontally_stretchable = "on"
}
data.raw["gui-style"].default["lrh_vertical_shallow_frame"] = {
    type = "frame_style",
    parent = "lrh_shallow_frame",
    vertically_stretchable = "on"
}

-- -- Scroll panes

data.raw["gui-style"].default["lrh_vertical_scroll_pane"] = {
    type = "scroll_pane_style",
    parent = "scroll_pane",
    horizontally_stretchable = "on",
    extra_padding_when_activated = 0,
    padding = 4,
    right_margin = 12,
    always_draw_borders = true,
    vertically_stretchable = "stretch_and_expand",
    scrollbars_go_outside = true
}

data.raw["gui-style"].default["lrh_slot_scroll"] = {
    type = "scroll_pane_style",
    parent = "deep_slots_scroll_pane",
    extra_padding_when_activated = 0,
    padding = 4,
    right_margin = 12,
    always_draw_borders = true,
    scrollbars_go_outside = true,
    -- vertically_stretchable = "stretch_and_expand",
    vertically_stretchable = "on",
    vertically_squashable = "on"
}
