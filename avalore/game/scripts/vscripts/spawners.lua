if Spawners == nil then
    Spawners = {}
end

require("constants")

-- Initialize & Cache a bunch of handles/entities so we can easily grab
-- a reference to them when working with it later
function Spawners:Init()
    -- GameTime in seconds to start splitting the middle wave around the center (mostly for debug)
    Spawners.iSplitTime = 60 --Constants.TIME_ROUND_2_START

    -- Spawning Handles (Entities)
    Spawners.h_RadiantSpawn_Top     = Entities:FindByName(nil, "spawner_good_top")
    Spawners.h_RadiantSpawn_Mid_A   = Entities:FindByName(nil, "spawner_good_mid")
    Spawners.h_RadiantSpawn_Mid_B   = Entities:FindByName(nil, "spawner_good_midb")
    Spawners.h_RadiantSpawn_Bot     = Entities:FindByName(nil, "spawner_good_bot")

    Spawners.h_DireSpawn_Top     = Entities:FindByName(nil, "spawner_bad_top")
    Spawners.h_DireSpawn_Mid_A   = Entities:FindByName(nil, "spawner_bad_mid")
    Spawners.h_DireSpawn_Mid_B   = Entities:FindByName(nil, "spawner_bad_midb")
    Spawners.h_DireSpawn_Bot     = Entities:FindByName(nil, "spawner_bad_bot")

    -- Initial Path Node Handles (Entities)
    Spawners.h_RadiantInit_Top          = Entities:FindByName(nil, "radiant_path_top_1")
    Spawners.h_RadiantInit_Mid_Main     = Entities:FindByName(nil, "radiant_path_start")
    Spawners.h_RadiantInit_Mid_AltA     = Entities:FindByName(nil, "radiant_path_mid_1a")
    Spawners.h_RadiantInit_Mid_AltB     = Entities:FindByName(nil, "radiant_path_mid_1b")
    Spawners.h_RadiantInit_Bot          = Entities:FindByName(nil, "radiant_path_bot_1")

    Spawners.h_DireInit_Top          = Entities:FindByName(nil, "dire_path_top_1")
    Spawners.h_DireInit_Mid_Main     = Entities:FindByName(nil, "dire_path_start")
    Spawners.h_DireInit_Mid_AltA     = Entities:FindByName(nil, "dire_path_mid_1a")
    Spawners.h_DireInit_Mid_AltB     = Entities:FindByName(nil, "dire_path_mid_1b")
    Spawners.h_DireInit_Bot          = Entities:FindByName(nil, "dire_path_bot_1")

    -- Create Spawn Configs to Loop Through
    -- Key = Location; Value = {Spawner, FirstWaypoint, MeleeCreepToUse, RangedCreepToUse, Siege, Team}
    -- we can then loop through these to spawn on spawn intervals
    -- but they can be updated in other places (e.g. on rax death to change the creep to super/mega)
    -- start the alt routes spawners as nil so they don't spawn until at 10 min they get forced to start up
    Spawners.SpawnConfigs = {}
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_TOP]   = {Spawner = self.h_RadiantSpawn_Top,   FirstWaypoint = self.h_RadiantInit_Top,      Melee = "npc_dota_creep_goodguys_melee", Ranged = "npc_dota_creep_goodguys_ranged", Siege = "npc_dota_goodguys_siege", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs["Radiant_MidA"]  = {Spawner = self.h_RadiantSpawn_Mid_A, FirstWaypoint = self.h_RadiantInit_Mid_Main, Melee = "npc_dota_creep_goodguys_melee", Ranged = "npc_dota_creep_goodguys_ranged", Siege = "npc_dota_goodguys_siege", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs["Radiant_MidB"]  = {Spawner = nil,                       FirstWaypoint = self.h_RadiantInit_Mid_AltB, Melee = "npc_dota_creep_goodguys_melee", Ranged = "npc_dota_creep_goodguys_ranged", Siege = "npc_dota_goodguys_siege", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs["Radiant_Bot"]   = {Spawner = self.h_RadiantSpawn_Bot,   FirstWaypoint = self.h_RadiantInit_Bot,      Melee = "npc_dota_creep_goodguys_melee", Ranged = "npc_dota_creep_goodguys_ranged", Siege = "npc_dota_goodguys_siege", Team = DOTA_TEAM_GOODGUYS }

    Spawners.SpawnConfigs["Dire_Top"]   = {Spawner = self.h_DireSpawn_Top,   FirstWaypoint = self.h_DireInit_Top,       Melee = "npc_dota_creep_badguys_melee", Ranged = "npc_dota_creep_badguys_ranged", Siege = "npc_dota_badguys_siege", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs["Dire_MidA"]  = {Spawner = self.h_DireSpawn_Mid_A, FirstWaypoint = self.h_DireInit_Mid_Main,  Melee = "npc_dota_creep_badguys_melee", Ranged = "npc_dota_creep_badguys_ranged", Siege = "npc_dota_badguys_siege", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs["Dire_MidB"]  = {Spawner = nil,                    FirstWaypoint = self.h_DireInit_Mid_AltB,  Melee = "npc_dota_creep_badguys_melee", Ranged = "npc_dota_creep_badguys_ranged", Siege = "npc_dota_badguys_siege", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs["Dire_Bot"]   = {Spawner = self.h_DireSpawn_Bot,   FirstWaypoint = self.h_DireInit_Bot,       Melee = "npc_dota_creep_badguys_melee", Ranged = "npc_dota_creep_badguys_ranged", Siege = "npc_dota_badguys_siege", Team = DOTA_TEAM_BADGUYS }

    print("Spawners Initialized")
end

--===================================
-- LANE CREEPS
--===================================

--[[ 
    RADIANT
        * spawner_good_top ==> radiant_path_top_1 ==> radiant_path_top_2 ==> radiant_path_end
        * spawner_good_bot ==> radiant_path_bot_1 ==> radiant_path_bot_2 ==> radiant_path_end
        Min 0-10:
        * spawner_good_mid ==> radiant_path_start ==> radiant_path_mid_1 ==> radiant_path_end
        Min 10+:
        * spawner_good_mid ==> radiant_path_mid_1a ==> radiant_path_mid_right1 => radiant_path_mid_right2 => radiant_path_mid_right3 => radiant_path_mid_recombine ==> radiant_path_end
        * spawner_good_midb => radiant_path_mid_1b ==> radiant_path_mid_left1 ==> radiant_path_mid_left2 ==> radiant_path_mid_left3 ==> radiant_path_mid_recombine ==> radiant_path_end
    DIRE
        * spawner_bad_top ==> dire_path_top_1 ==> dire_path_top_2 ==> dire_path_end
        * spawner_bad_bot ==> dire_path_bot_1 ==> dire_path_bot_2 ==> dire_path_end
        Min 0-10:
        * spawner_bad_mid ==> dire_path_start ==> dire_path_mid_1 ==> dire_path_end
        Min 10+:
        * spawner_bad_mid ==> dire_path_mid_1a ==> dire_path_mid_right1 => dire_path_mid_right2 => dire_path_mid_right3 => dire_path_mid_recombine ==> dire_path_end
        * spawner_bad_midb => dire_path_mid_1b ==> dire_path_mid_left1 ==> dire_path_mid_left2 ==> dire_path_mid_left3 ==> dire_path_mid_recombine ==> dire_path_end

    NOTE: Spawner and first waypoint are controlled programmatically, the rest is done via the entities on the map itself
--]]

function Spawners:DetermineNumMeleeToSpawn(iGameTimeSeconds, sLaneKey)
    local iNum = 0
    if iGameTimeSeconds < 600 then
        iNum = 3
    elseif iGameTimeSeconds < 1200 then
        iNum = 4
    elseif iGameTimeSeconds < 1800 then
        iNum = 5
    else
        iNum = 6
    end

    -- once the lanes start splitting, we don't need to send as many creeps or there will be
    -- way too much XP on the map
    if (iGameTimeSeconds > self.iSplitTime and string.find(sLaneKey, "Mid")) then 
        iNum = iNum - 2
    end

    return iNum
end

function Spawners:DetermineNumRangedToSpawn(iGameTimeSeconds, sLaneKey)
    local iNum = 0
    if iGameTimeSeconds < 1200 then
        iNum = 1
    else
        iNum = 2
    end

    -- once the lanes start splitting, we don't need to send as many creeps or there will be
    -- way too much XP on the map
    if (iGameTimeSeconds > self.iSplitTime and string.find(sLaneKey, "Mid")) then 
        iNum = math.ceil(iNum / 2)
    end

    return iNum
end

--[[
function Spawners:SpawnRadiantMidCreeps(iGameTimeSeconds)
    local iMeleeToSpawn = self:DetermineMeleeToSpawn(iGameTimeSeconds)
    local spawner = self.h_RadiantSpawn_Mid_B
    for i = 1,iMeleeToSpawn,1
    do
        local creep = CreateUnitByName( "npc_dota_creep_goodguys_melee", spawner:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS )
        creep.hSpawner = spawner
        if iGameTimeSeconds > 60 then
            creep:SetInitialGoalEntity(self.h_RadiantInit_Mid_AltB)
        else
            creep:SetInitialGoalEntity(self.h_RadiantInit_Mid_Main)
        end
    end
end
--]]

-- When Spawners.iSplitTime has elapsed, this is called to split the waves around the middle
-- pit instead of going through it.
function Spawners:SplitLanes()
    --print("Starting Lane Split")
    self.SpawnConfigs["Radiant_MidA"].FirstWaypoint = self.h_RadiantInit_Mid_AltA

    self.SpawnConfigs["Radiant_MidB"].Spawner       = self.h_RadiantSpawn_Mid_B
    self.SpawnConfigs["Radiant_MidB"].FirstWaypoint = self.h_RadiantInit_Mid_AltB

    self.SpawnConfigs["Dire_MidA"].FirstWaypoint    = self.h_DireInit_Mid_AltA

    self.SpawnConfigs["Dire_MidB"].Spawner          = self.h_DireSpawn_Mid_B
    self.SpawnConfigs["Dire_MidB"].FirstWaypoint    = self.h_DireInit_Mid_AltB
end

-- Loop through the spawn configs and create the creep waves
function Spawners:SpawnLaneCreeps(iGameTimeSeconds)
    --print("GameTime = " .. tostring(iGameTimeSeconds) .. ", \tEval = " .. tostring(math.floor(iGameTimeSeconds) % 30))
    --print("Start Spawning Waves...")
    if iGameTimeSeconds == self.iSplitTime then
        self:SplitLanes()
    end

    for key,value in pairs(self.SpawnConfigs) do
        if value.Spawner ~= nil then
            --print("Spawning for key " .. key .. " \t\t| At Spawner: " .. value.Spawner:GetName() .. " \t\t| With Goal: " .. value.FirstWaypoint:GetName())
            -- spawn melee creeps
            for i = 1, self:DetermineNumMeleeToSpawn(iGameTimeSeconds, key), 1 do
                local creep = CreateUnitByName( value.Melee, value.Spawner:GetOrigin(), true, nil, nil, value.Team )
                creep:SetInitialGoalEntity(value.FirstWaypoint)
            end

            -- spawn ranged creeps
            for i = 1, self:DetermineNumRangedToSpawn(iGameTimeSeconds, key), 1 do
                local creep = CreateUnitByName( value.Ranged, value.Spawner:GetOrigin(), true, nil, nil, value.Team )
                creep:SetInitialGoalEntity(value.FirstWaypoint)
            end
        end
    end
    --print("End Spawning Waves...")
end