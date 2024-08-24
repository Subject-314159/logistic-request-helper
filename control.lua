local gui = require("scripts.gui")

local init = function()
    for _, p in pairs(game.players) do
        gui.force_close(p.index)
    end
end

script.on_configuration_changed(function()
    init()
end)

script.on_init(function()
    init()
end)

script.on_event(defines.events.on_tick, function(e)
    gui.tick_update()
end)

----------------------------------------------------------------------------------------------------
-- GUI toggle
----------------------------------------------------------------------------------------------------

script.on_event(defines.events.on_lua_shortcut, function(e)
    local player = game.get_player(e.player_index)
    if not player then
        return
    end
    if e.prototype_name == "lrh_shortcut" then
        gui.toggle(e.player_index, true)
    end
end)

script.on_event("lrh_shortcut", function(e)
    gui.toggle(e.player_index, true)
end)

script.on_event(defines.events.on_gui_click, function(e)
    -- Get the player
    local player = game.get_player(e.player_index)
    if not player then
        return
    end

    -- Check for our button
    local name = e.element.name
    if name == "lrh_btn" or name == "lrh_min" or name == "lrh_max" then
        local btn = e.element
        local right = e.button == defines.mouse_button_type.right
        gui.on_button_clicked(player, btn, e.shift, e.control, e.alt, right)
    elseif name == "lrh_expand_group" then
        player.print("Sorry, this functionality is not yet implemented")
    end

end)

script.on_event({defines.events.on_gui_opened, defines.events.on_gui_closed}, function(e)
    local player = game.get_player(e.player_index)
    if not player then
        return
    end

    -- Check for character crafting window
    if e.gui_type == defines.gui_type.controller then
        gui.toggle(e.player_index, false)
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(e)
    -- Force close our GUI and the character screen if one of our mod settings changed
    if e.setting_type == "runtime-per-user" and string.sub(e.setting, 1, 4) == "lrh_" then
        gui.force_close(e.player_index)
    end
end)
