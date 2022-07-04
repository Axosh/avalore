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
    elseif input == "spawn enemy" then
        local enemy_team = DOTA_TEAM_BADGUYS
        local team_localized = "Dire"
        if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            enemy_team = DOTA_TEAM_GOODGUYS
            team_localized = "Radiant"
        end
        --local temp_hero = CreateUnitByName("npc_dota_hero_rubick", Vector(7232, 7232, 256), true, nil, hero:GetOwner(), DOTA_TEAM_BADGUYS)
        --local temp_hero = CreateUnitByName("npc_dota_hero_rubick", Vector(0, 0, 0), true, nil, hero:GetOwner(), enemy_team)
        local temp_hero = CreateUnitByName("npc_dota_hero_sniper", Vector(0, 0, 0), true, nil, hero:GetOwner(), enemy_team)
        temp_hero:SetControllableByPlayer(0, false)
        temp_hero:AddNewModifier(nil, nil, "modifier_provide_vision", {})
        local level = 30
        while (level > 0) do
            temp_hero:HeroLevelUp(false)
            level = level - 1
        end
        print("Created ... " .. temp_hero:GetUnitName() .. " on team .. " .. team_localized)
        for key, value in pairs(Spawners.MercCamps[enemy_team]) do
			--print("Giving Player " .. tostring(hPlayerHero:GetPlayerOwnerID()) .. " shared control of " .. tostring(key))
			value:SetControllableByPlayer(hero:GetPlayerOwnerID(), false)
		end
    elseif string.find(input, "spawn unit") then
        local arr = StringToArrayByWhitespace(input)
        local unit_arg = arr[3] -- lua is 1-indexed for this stuff
        print(unit_arg)
        local unit = CreateUnitByName(unit_arg, hero:GetAbsOrigin(), true, nil, hero:GetOwner(), hero:GetTeamNumber())
        unit:SetControllableByPlayer(0, false)
        unit:AddNewModifier(nil, nil, "modifier_provide_vision", {})
        print("Created ... " .. unit:GetUnitName())
        PrintVector(unit:GetAbsOrigin(), "at location")
    elseif input == "black sheep wall" then
        AddFOWViewer(hero:GetTeamNumber(), Vector(0,0,0), 8000, 600, false)
        AddFOWViewer(hero:GetTeamNumber(), Vector(1000,6000,0), 8000, 600, false)
        AddFOWViewer(hero:GetTeamNumber(), Vector(6000,1000,0), 8000, 600, false)
        AddFOWViewer(hero:GetTeamNumber(), Vector(-6000,-1000,0), 8000, 600, false)
        AddFOWViewer(hero:GetTeamNumber(), Vector(-1000,-6000,0), 8000, 600, false)
        for x=1,4,1 do
            for y=1,4,1 do
                AddFOWViewer(hero:GetTeamNumber(), Vector(x * 4000, y * 4000, 0), 8000, 600, false)
                AddFOWViewer(hero:GetTeamNumber(), Vector(x * -4000, y * 4000, 0), 8000, 600, false)
                AddFOWViewer(hero:GetTeamNumber(), Vector(x * 4000, y * -4000, 0), 8000, 600, false)
                AddFOWViewer(hero:GetTeamNumber(), Vector(x * -4000, y * -4000, 0), 8000, 600, false)
            end
        end
    -- elseif input == "level up" then
    --     hero:HeroLevelUp(false)
    --elseif string.find(input, "add levels") then
    elseif string.find(input, "level up") then
        local arr = StringToArrayByWhitespace(input)
        local level = 1
        if arr[3] ~= nil then
            level = tonumber(arr[3])
        end
        while (level > 0) do
            hero:HeroLevelUp(false)
            level = level - 1
        end
    elseif string.find(input, "set gold") then
        local arr = StringToArrayByWhitespace(input)
        local gold = tonumber(arr[3])
        hero:SetGold(gold, true)
    elseif input == "debug loc" then
        IsOnRadiantSide(hero:GetAbsOrigin().x, hero:GetAbsOrigin().y)
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
    local cnt = 1 -- lua is 1-indexed for this stuff
    for token in string.gmatch(input_string, "[^%s]+") do
        print("[" .. tostring(cnt) .. "] = \"" .. token .. "\"")
        table.insert(result_array, token)
        cnt = cnt + 1
    end
    return result_array
end