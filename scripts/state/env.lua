local env = {}

local init_quality = function()
    -- Ensure storage
    storage.quality = storage.quality or {}
    for _, q in pairs(prototypes.quality) do
        -- Ensure/add storage entry for next
        storage.quality[q.name] = storage.quality[q.name] or {}
        if q.next then
            storage.quality[q.name].next = q.next.name
        end

        -- Ensure/add storage entry for previous
        if q.next then
            storage.quality[q.next.name] = storage.quality[q.next.name] or {}
            storage.quality[q.next.name].previous = q.name
        end
    end

    -- Find the one quality with no previous quality
    for n, q in pairs(storage.quality) do
        if not q.previous then
            storage.base_quality = n
            break
        end
    end
end

env.get_base_quality = function()
    return storage.base_quality
end
env.get_all_quality = function()
    return storage.quality
end

local init_groups = function()
    -- Generate group-subgroup-order array
    local groups = {}

    local fltr = {{
        filter = "is-parameter",
        mode = "and",
        invert = true
    }, {
        filter = "selection-tool",
        mode = "and",
        invert = true
    }, {
        filter = "flag",
        flag = "only-in-cursor",
        mode = "and",
        invert = true
    }}
    local items = prototypes.get_item_filtered(fltr)

    for _, itm in pairs(items) do
        if not itm.hidden then
            -- Get some variables to work with
            local igrp = itm.group.order .. "_" .. itm.group.name
            local isubg = itm.subgroup.order .. "_" .. itm.subgroup.name
            local iname = itm.order .. "_" .. itm.name

            -- Ensure group index & populate
            groups[igrp] = groups[igrp] or {} -- Ensure groups has this group index
            local gg = groups[igrp]
            gg.name = itm.group.name -- Set the group name

            gg.subgroups = gg.subgroups or {} -- Ensure subgroups array
            gg.subgroups[isubg] = gg.subgroups[isubg] or {} -- Ensure this subgroup index exists
            local ggs = gg.subgroups[isubg]
            ggs.name = itm.subgroup.name -- Set the subgroup name

            ggs.items = ggs.items or {} -- Ensure items array
            ggs.items[iname] = itm.name -- Set item name
        end
    end

    storage.groups = groups

end

env.get_groups = function()
    return storage.groups
end

env.init = function()
    init_quality()
    init_groups()
end

return env
