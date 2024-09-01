local const = require("lib.const")
local util = require("lib.util")

local request = {}

local get_callback = function(type, target)
    local callback
    if type == const.request_types.character then
        callback = target.get_personal_logistic_slot
    elseif type == const.request_types.vehicle then
        callback = target.get_vehicle_logistic_slot
    elseif type == const.request_types.container then
        callback = target.get_request_slot
    end
    return callback
end

local get_empty_request_slot = function(request_type, target)
    local max
    if request_type == const.request_types.container then
        max = const.max_slots.container
    else
        max = const.max_slots.logistics
    end

    local i = 1
    while i < max do
        local slot
        if request_type == const.request_types.character then
            slot = target.get_personal_logistic_slot(i)
        elseif request_type == const.request_types.vehicle then
            slot = target.get_vehicle_logistic_slot(i)
        elseif request_type == const.request_types.container then
            slot = target.get_request_slot(i)
        end
        if not slot or not slot.name then
            return i
        end
        i = i + 1
    end
end

local get_requests = function(callback, max)
    if not max then
        max = const.max_slots.logistics
    end

    local requests = {}
    local i = 1
    local empty_slots = 0
    while empty_slots < const.max_slots.empty and i <= max do
        local slot = callback(i)
        if slot and slot.name then
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

request.get_index = function(index, type, target)
    local callback = get_callback(type, target)
    return callback(index)
end

request.get_all = function(type, target)
    local callback = get_callback(type, target)
    return get_requests(callback)
end

------------------------------------------------------------------------------------------------
-- Button click handlers
----------------------------------------------------------------------------------------------------

request.on_button_clicked = function(player, button, request_type, shift, control, alt, right)
    local btn = button
    local itm = game.item_prototypes[btn.tags.name]

    -- Get current count
    -- local requests = get_requests(player)
    local target
    -- Correct request type for closed window
    request_type = request_type or const.request_types.character
    if request_type == const.request_types.character then
        target = player
    else
        target = player.opened
    end
    local requests = request.get_all(request_type, target)
    local ireq = requests[btn.tags.name] or {
        min = 0,
        max = 0,
        index = get_empty_request_slot(request_type, target)
    }
    local min = ireq.min or ireq.count
    local max = ireq.max or ireq.count
    local i = ireq.index

    -- Add or subtract amount
    if right then
        -- Right mouse button to clear immediately, disregard any other controls
        max = -1
    else
        if shift and requests[btn.tags.name] and max == 0 then
            -- The request amount was already 0 so we need to clear it later
            max = -1
        else
            -- Get amount to add or subtract
            local add = itm.stack_size
            if shift then
                add = add * -1
            end

            -- Add or subtract from min/max
            if request_type == const.request_types.container then
                -- Chests only have one request amount, set both min/max
                min = min + add
                max = max + add
            else
                if control or (not control and not alt) then
                    max = max + add
                end
                if alt or (not control and not alt) then
                    min = min + add
                end
            end

            -- Correct if min/max/delta is negative
            if min > max then
                if shift then
                    -- If we subtracted from min then min would never be >max so we set min to max
                    min = max
                else
                    -- If we added to min then max would never be <min so we set max to min
                    max = min
                end
            end
            min = math.min(math.max(min, 0), 4294967295)
            max = math.min(math.max(max, 0), 4294967295)

            -- Correct zero for logistic Chests
            if request_type == const.request_types.container and max == 0 then
                max = -1
            end
        end
    end

    -- Set or clear new logistic request amount

    if request_type == const.request_types.character then
        if max == -1 then
            player.clear_personal_logistic_slot(i)
        else
            local req = {
                name = btn.tags.name,
                min = min,
                max = max
            }
            player.set_personal_logistic_slot(i, req)
        end
    elseif request_type == const.request_types.vehicle then
        if max == -1 then
            player.opened.clear_vehicle_logistic_slot(i)
        else
            local req = {
                name = btn.tags.name,
                min = min,
                max = max
            }
            player.opened.set_vehicle_logistic_slot(i, req)
        end
    elseif request_type == const.request_types.container then

        if max == -1 then
            player.opened.clear_request_slot(i)
        else
            local req = {
                name = btn.tags.name,
                count = max
            }
            player.opened.set_request_slot(req, i)
        end
    end
end

return request
