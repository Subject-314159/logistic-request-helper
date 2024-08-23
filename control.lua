local gui = require("scripts.gui")

local init = function()
end

script.on_configuration_changed(function()
    init()
end)

script.on_init(function()
    init()
end)

script.on_event(defines.events.on_tick, function(e)
end)

script.on_event(defines.events.on_lua_shortcut, function(e)
    local player = game.players[e.player_index]
    if not player then
        return
    end
    if e.prototype_name == "lrh_shortcut" then
        gui.build(e.player_index)
    end
end)

script.on_event(defines.events.on_gui_click, function(e)
    -- Get the player
    local player = game.get_player(e.player_index)
    if not player then
        return
    end

    -- Check for our button
    if e.element.name == "lrh_btn" then
        local btn = e.element
        local right = e.button == defines.mouse_button_type.right
        gui.on_button_clicked(player, btn, e.shift, e.control, e.alt, right)
    elseif e.element.name == "lrh_expand_group" then
        player.print("Sorry, this functionality is not yet implemented")
    end

end)

-- script.on_event(defines.events.on_gui_opened, function(e)
--     game.print("Opened GUI")
--     if e.gui_type ~= defines.gui_type.research then
--         local player = game.get_player(e.player_index)
--         if player and player.gui.screen.lrh_gui then
--             player.gui.screen.lrh_gui.destroy()
--             player.opened = nil
--             return
--         end
--     end
-- end)
