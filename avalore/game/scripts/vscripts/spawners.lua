if Spawners == nil then
    Spawners = {}
end

function Spawners:Init()
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
        * spawner_good_mid ==> 
        * spawner_good_midb => radiant_path_mid_1b ==> radiant_path_mid_left2 ==> radiant_path_mid_left3 ==> radiant_path_mid_recombine ==> radiant_path_end
    DIRE
--]]

function Spawners:DetermineMeleeToSpawn(iGameTimeSeconds)
    if iGameTimeSeconds < 600 then
        return 3
    elseif iGameTimeSeconds < 1200 then
        return 4
    elseif iGameTimeSeconds < 1800 then
        return 5
    else
        return 6
    end
end

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

function Spawners:SpawnLaneCreeps(iGameTimeSeconds)
    self:SpawnRadiantMidCreeps(iGameTimeSeconds)
end