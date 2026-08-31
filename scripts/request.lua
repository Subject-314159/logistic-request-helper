local const = require("lib.const")
local util = require("lib.util")
local state = require("scripts.state")
local gutil = require("scripts.gui.gutil")

local request = {}

request.set_safe = function(section, slot, filter)
    -- if not section.is_manual then
    --     return "Unable to set filters when group is not manual"
    -- end

    -- Try to set the slot
    local success, result = pcall(function()
        section.set_slot(slot, filter)
    end)
    if not success or result then
        return result
    end
    local new = section.get_slot(slot)
    if (not new or not new.value) and filter and filter.value then
        return "Filter conflicts with an existing request"
    end
end

local get_filter_slot = function(player, section, signal)
    if not section or not section.filters_count or section.filters_count == 0 then
        return nil, 1
    end

    -- Get the slot for this signal
    local curslot = 1
    local firstempty
    local numslots = 0
    local filter
    local q = state.get_player_quality(player)
    local com = state.get_player_comparator(player)
    local c
    if com > 1 then
        c = const.comparators[com]
    end

    while true do
        -- Check if the current slot is our signal
        filter = section.get_slot(curslot)
        if filter and filter.value and filter.value.name == signal and filter.value.comparator == c and
            filter.value.quality == q then
            -- We found our slot so we can exit the loop
            break
        end
        -- Remember the first emtpy slot
        if (not filter or not filter.value) and not firstempty then
            firstempty = curslot
        end

        -- Prepare for next slot
        curslot = curslot + 1

        -- Check if we had all filters
        numslots = numslots + 1
        if numslots == section.filters_count then
            -- We processed all filters so there is nothing more to come
            -- We need to get an empty slot, so revert to the first next empty one
            if firstempty then
                curslot = firstempty
            end
            filter = nil
            break
        end

        -- Emergency handbrake
        if curslot > 1000 then
            game.print("[LRH] Warning: Too many filters")
            filter = nil
            break
        end
    end

    return filter, curslot
end

local make_filter_modify = function(player, filter, signal, button, control, shift, alt)
    -- Get variables
    local eq = control == shift
    local left = button == defines.mouse_button_type.left
    local right = button == defines.mouse_button_type.right

    -- Get stack size
    local action = state.get_player_action(player)
    local stack = prototypes.item[signal].stack_size
    if action == const.gui.actions.half_stack then
        stack = math.floor(stack / 2)
    elseif action == const.gui.actions.rocket_load then
        stack = util.get_rocket_capacity(signal)
    end
    if right then
        stack = stack * -1
    end

    -- Update filter
    if alt then
        if left then
            -- Set max to infinite
            filter.max = nil
            if not filter.min then
                filter.min = stack
            end
        elseif right then
            filter = {}
        end
    else
        -- Process min
        if eq or control then
            -- Ensure min
            if not filter.min then
                -- There is no request yet for this item, initiate both min and max
                filter.min = 0
                filter.max = filter.max or 0
            end
            -- Increase/decrease min by 1 stack
            filter.min = filter.min + stack
        end

        -- Process max
        if eq or shift then
            if not filter.min then
                filter.min = 0
            end
            if filter.max then
                -- Increase/decrease max by 1 stack if it is not infinite
                filter.max = filter.max + stack
            elseif left then
                filter.max = stack
            elseif right then
                -- Set max to 10 stacks
                -- Multiply by -10 because stack is negative here
                filter.max = -10 * stack
            end
        end
    end
end

local make_filter_set = function(player, filter, signal)

    -- Get stack size
    local action = state.get_player_action(player)
    local stack = prototypes.item[signal].stack_size

    if action == const.gui.actions.stack_0_1 then
        filter.min = 0
        filter.max = stack
    elseif action == const.gui.actions.stack_1_2 then
        filter.min = stack
        filter.max = (2 * stack)
    end
end

request.handle = function(player, section, signal, button, control, shift, alt)
    -- Early exit if no mouse button pressed (god knows why we end up here)
    if button == defines.mouse_button_type.none then
        return
    end

    -- Get some variables to work with
    local txt = {
        create_at_cursor = true
    }

    -- Early exit if we did not get a section
    if not section then
        txt.text = "Unable to process, please select a section first"
        player.create_local_flying_text(txt)
        return
    end

    -- Early exit if the signal is not an item
    if not prototypes.item[signal] then
        txt.text = signal .. "is not an item, this action is currently unsupported"
        player.create_local_flying_text(txt)
        return
    end

    -- Early exit if the section is not manual
    if not section.is_manual and not gutil.player_opened_platform(player) then
        txt.text = "Unable to process, selected section is circuit controlled"
        player.create_local_flying_text(txt)
    end

    -- Handles a button press
    -- signal = item-name
    -- First we need to get the active section
    -- Then we need to determine the slot in which to put this request;
    --      Iterate over the slots, keep manual counter (because there might be empty slots) until we reach filters_count
    --      Use the index at which we stop - either we found the index for existing signal, or the first next empty slot
    -- Next we need to determine the new filter settings based on the button combination
    -- Last we need to try to set this filter safely, or notify user of invalid filter setting
    local filter, curslot = get_filter_slot(player, section, signal)

    -- Ensure filter
    if not filter or not filter.value then
        filter = {
            value = {
                name = signal -- Do not set yet because we need to check if this is a new one or not
            }
        }
    end

    -- Get quality
    local q = state.get_player_quality(player)
    local com = state.get_player_comparator(player)

    -- Handle the action
    -- Left click: Increase by 1 stack (i.e. set to 1 stack if none)
    -- Right click: Decrease by 1 stack
    -- No modifier: Both equally
    -- Control: Min amount
    -- Control + Shift: Both equally
    -- Shift: Max amount
    -- Alt + left click: Max to infinite (if no value exists then new min = 1 stack, ignores ctrl/shift)
    -- Alt + right click: Clear
    -- Right click + infinite: new max = 10 stacks (or min if new min is >10 stacks)
    -- (Control or Control + Shift) + Left click new: Set both to 1 stack
    -- Shift + Left click new: min = 0 stack & max = 1 stack
    -- Shift + Left click inf.: Ignore
    -- Right click + new = 0 stack both

    if button == defines.mouse_button_type.middle then
        -- Clear the filter
        filter = {}
    else
        local action = state.get_player_action(player)
        if util.array_has_value(
            {const.gui.actions.default, const.gui.actions.half_stack, const.gui.actions.rocket_load}, action) then
            make_filter_modify(player, filter, signal, button, control, shift, alt)
        else
            make_filter_set(player, filter, signal)
        end
    end

    -- Ensure positive and max >= min
    if filter.min and filter.min < 0 then
        filter.min = 0
    end
    if filter.max and filter.max < 0 then
        filter.max = 0
    end
    if filter.max and filter.max < filter.min then
        if button == defines.mouse_button_type.left then
            filter.max = filter.min
        else
            filter.min = filter.max
        end
    end

    -- If the comparator is not = then min always needs to be 0
    if com ~= 2 then
        filter.min = 0
    end

    -- Set quality
    if filter.value then
        filter.value.quality = q
        if com > 1 then
            filter.value.comparator = const.comparators[com]
        end
    end

    -- Set planet import
    if gutil.player_opened_platform(player) then
        local pl = state.get_player_planet(player)
        if pl == const.gui.planet_default then
            pl = nil
        end
        filter.import_from = pl
    end

    -- Set the filter
    local res = request.set_safe(section, curslot, filter)
    if res then
        txt.text = res
        player.create_local_flying_text(txt)
    end
end

request.set_planet = function(player, section)
    if not player or not section or not gutil.player_opened_platform(player) then
        return
    end
    local pl = state.get_player_planet(player)
    for i, f in ipairs(section.filters) do
        if pl == const.gui.planet_default then
            f.import_from = prototypes[f.value.name].default_import_location.name
        else
            f.import_from = pl
        end
        request.set_safe(section, i, f)
    end
end

local get_single_filter = function(player, section, item)
    local fltr
    local cnt = 0
    local slot
    for i, f in ipairs(section.filters) do
        if f.value and f.value.name == item then
            fltr = f
            slot = i
            cnt = cnt + 1
        end
    end
    if cnt == 1 then
        return slot, fltr
    end
end
local update_quality = function(player, section, item, increase)
    if not section or not item then
        return
    end
    local slot, filter = get_single_filter(player, section, item)
    if not filter then
        local txt = {
            create_at_cursor = true,
            text = "Only available when there is exactly one existing requests"
        }
        player.create_local_flying_text(txt)
        return
    end
    local quals = state.get_all_quality()
    local cur = filter.value.quality or state.get_base_quality()
    if increase then
        if quals[cur] and quals[cur].next then
            filter.value.quality = quals[cur].next
        end
    else
        if quals[cur] and quals[cur].previous then
            filter.value.quality = quals[cur].previous
        end
    end
    request.set_safe(section, slot, filter)
end
request.increase_quality = function(player, section, item)
    update_quality(player, section, item, true)
end
request.decrease_quality = function(player, section, item)
    update_quality(player, section, item, false)
end

return request
