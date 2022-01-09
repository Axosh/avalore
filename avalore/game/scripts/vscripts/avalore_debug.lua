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
    elseif input == "debug modifiers" then
        print("===== Debug Modifiers =====")
        for _,mod in pairs(hero:FindAllModifiers()) do
            print(mod:GetName())
        end
    elseif string.find(input, "add_gametime") then
        -- offset gametime in seconds
        local arr = StringToArrayByWhitespace(input)
        print("Parsed Args:")
        PrintTable(arr)
        local gametime = arr[2]
        local try_offset = tonumber(gametime)
        if try_offset then
            _G.time_offset = _G.time_offset + try_offset
        else
            print("Error parsing number")
        end
    elseif input == "gametime" then
        local curr_gametime = GameRules:GetDOTATime(false, false)
        curr_gametime = curr_gametime + _G.time_offset
        print("Current Gametime + Offset = " .. tostring(curr_gametime))
    end
    
end

-- ========================================================================================
-- delimit a string by whitespace and split into
-- tokens and stuff those into an array like any
-- split function (except 1-indexed instead of 0-indexed)
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
-- ========================================================================================
function StringToArrayByWhitespace(input_string)
    local result_array = {}
    for token in string.gmatch(input_string, "[^%s]+") do
        print("\"" .. token .. "\"")
        table.insert(result_array, token)
    end
    return result_array
end