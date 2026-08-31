local const = {}

const.settings = {
    window_position = "lrh_window-position",
    window_position_values = {
        right = "lrhval_right",
        left = "lrhval_left",
        floating = "lrhval_floating"
    },
    link_quality_control = "lrh_separate-quality-shortcut"
}

const.gui = {
    tag = "lrh_on_gui",
    handler = {
        tab_click = "tab_click",
        item_click = "item_click",
        planet_click = "planet_click",
        group_change = "group_change",
        comparator_change = "comparator_change",
        quality_click = "quality_click",
        all_planet_click = "set_all_planet",
        on_action_change = "on_action_change",
        maximize_click = "maximize_click"
    },
    actions = {
        default = "default",
        half_stack = "half_stack",
        rocket_load = "rocket_load",
        stack_0_1 = "stack_0_1",
        stack_1_2 = "stack_1_2"
    },
    main = "lrh_gui",
    top = "top_frame",
    bottom = "bottom_frame",
    groups = "groups",
    tabs = "tabbed_pane",
    tabtbl = "tabbed_table",
    tabscroll = "tabbed_scroll_pane",
    expflow = "expansion_flow",
    actflow = "action_flow",
    qualflow = "quality_flow",
    comdrop = "comparator_dropdown",
    qualtbl = "quality_table",
    plntflow = "planet_flow",
    plnttbl = "planet_table",
    vdiv = "top_vertical_divider",
    hdiv = "top_horizontal_divider",
    existing = "lrh_existing_tab",
    existingfl = "lrh_existing_requests_flow",
    existingtbl = "lrh_existing_requests_table",
    dragger = "dragger",

    buttons_per_row = 10,
    circuit_controlled = "[Controlled by circuit network]",
    no_group = "[No group assigned]",
    planet_default = "default-planet-import"
}

const.comparators = {"[virtual-signal=signal-any-quality]", "=", ">", "<", "≥", "≤", "≠"}

return const
