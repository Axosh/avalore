require("controllers/inventory_manager")
--[[
    Utility functions for helping debug.
--]]

-- function DebugVector( vector )
--     local result = "(" .. tostring(vector.X) .. ", " .. tostring(vector.Y) .. ", " .. tostring(vector.Z) .. ")"
--     return result
-- end

-- ===================================================
-- player_chat
--     A public player chat.
-- ===================================================
-- teamonly: bool
--     True if team only chat.
-- userid: EntityIndex
--     Chatting player.
-- playerid: PlayerID
--     Chatting player ID.
-- text: string
-- ===================================================
function CAvaloreGameMode:ProcessPlayerMessage(event)
    local input = event.text
    input = string.lower(input) -- sanitize
    local hero = PlayerResource:GetSelectedHeroEntity(event.playerid)

    if input == "debug dota inv" then
        InventoryManager:DebugDotaSlots(hero)
    elseif input == "debug avalore inv" then
        InventoryManager:DebugAvaloreSlots(event.playerid)
    end
end