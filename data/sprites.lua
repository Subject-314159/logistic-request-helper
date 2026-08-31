local p = "__logistic-request-helper__/graphics/icons/"

local get_sprite = function(name, w, h)
    local prop = {
        type = "sprite",
        name = "lrh_" .. name,
        filename = p .. name .. ".png",
        priority = "extra-high-no-scale",
        width = w,
        height = h
    }
    return prop
end

data:extend({get_sprite("request", 32, 32), get_sprite("request_big", 64, 64)})
