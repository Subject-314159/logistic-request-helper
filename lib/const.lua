local const = {
    settings = {
        window_position = "lrh_window-position",
        window_position_values = {
            floating = "lrhval_floating",
            left = "lrhval_left",
            right = "lrhval_right"
        },

        group_by = "lrh_group-by",
        group_by_values = {
            dropdown = "lrhval_drop-down",
            tabs = "lrhval_tabs"
        },
        buttons_per_row = "lrh_buttons-per-row",
        buttons_per_row_values = {
            default = 10,
            min = 5,
            max = 20

        },
        window_height = "lrh_window-height",
        window_height_values = {
            default = 656,
            min = 300,
            max = 1200

        }
    },
    gui = {
        logistics_not_available = "lrh.not-available",
        window_title = {
            default = "lrh.title",
            vehicle = "lrh.title-vehicle",
            container = "lrh.title-chest"
        }
    },
    request_types = {
        character = "character",
        vehicle = "vehicle",
        container = "chest"
    },
    allowed_prototypes = {"spider-vehicle", "logistic-container", "infinity-container"},
    allowed_container_prototypes = {"logistic-container", "infinity-container"},
    allowed_container_modes = {"requester", "buffer"},
    allowed_vehicle_prototypes = {"spider-vehicle"},
    allowed_gui_types = {defines.gui_type.controller, defines.gui_type.entity} -- Not sure if this is required yet
    ,
    max_slots = {
        container = 1000,
        logistics = 65545,
        empty = 40
    },
    request = {
        no_group = "No group",
        no_subgroup = "No subgroup",
        no_order = "zzz"
    }
}

return const
