if Spawners == nil then
    Spawners = {}
end

require("constants")
require("references")
require("scripts/vscripts/libraries/map_and_nav")
require("controllers/demi_hero_manager")
--require("debug")

LinkLuaModifier( "modifier_flagbase", MODIFIER_FLAGBASE, LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shows_through_fog", MODIFIER_SHOWS_THROUGH_FOW, LUA_MODIFIER_MOTION_NONE )


-- Initialize & Cache a bunch of handles/entities so we can easily grab
-- a reference to them when working with it later
function Spawners:Init()
    -- GameTime in seconds to start splitting the middle wave around the center (mostly for debug)
    Spawners.iSplitTime = Constants.TIME_ROUND_2_START
    Spawners.iShelfInterval = 120
    Spawners.lanesAreSplit = false

    -- Spawning Handles (Entities)
    Spawners.h_RadiantSpawn_Top             = Entities:FindByName(nil, "spawner_good_top")
    Spawners.h_RadiantSpawn_Mid_A           = Entities:FindByName(nil, "spawner_good_mid")
    Spawners.h_RadiantSpawn_Mid_B           = Entities:FindByName(nil, "spawner_good_midb")
    Spawners.h_RadiantSpawn_Bot             = Entities:FindByName(nil, "spawner_good_bot")
    Spawners.h_RadiantSpawn_ShelfTop        = Entities:FindByName(nil, "spawner_good_shelf_top")
    Spawners.h_RadiantSpawn_ShelfBot        = Entities:FindByName(nil, "spawner_good_shelf_bot")

    Spawners.h_DireSpawn_Top                = Entities:FindByName(nil, "spawner_bad_top")
    Spawners.h_DireSpawn_Mid_A              = Entities:FindByName(nil, "spawner_bad_mid")
    Spawners.h_DireSpawn_Mid_B              = Entities:FindByName(nil, "spawner_bad_midb")
    Spawners.h_DireSpawn_Bot                = Entities:FindByName(nil, "spawner_bad_bot")
    Spawners.h_DireSpawn_ShelfTop           = Entities:FindByName(nil, "spawner_bad_shelf_top")
    Spawners.h_DireSpawn_ShelfBot           = Entities:FindByName(nil, "spawner_bad_shelf_bot")

    -- Initial Path Node Handles (Entities)
    Spawners.h_RadiantInit_Top              = Entities:FindByName(nil, "radiant_path_top_1")
    Spawners.h_RadiantInit_Mid_Main         = Entities:FindByName(nil, "radiant_path_start")
    Spawners.h_RadiantInit_Mid_AltA         = Entities:FindByName(nil, "radiant_path_mid_1a")
    Spawners.h_RadiantInit_Mid_AltB         = Entities:FindByName(nil, "radiant_path_mid_1b")
    Spawners.h_RadiantInit_Bot              = Entities:FindByName(nil, "radiant_path_bot_1")
    Spawners.h_RadiantInit_ShelfTop         = Entities:FindByName(nil, "radiant_path_shelf_top1")
    Spawners.h_RadiantInit_ShelfBot         = Entities:FindByName(nil, "radiant_path_shelf_bot1")

    Spawners.h_DireInit_Top                 = Entities:FindByName(nil, "dire_path_top_1")
    Spawners.h_DireInit_Mid_Main            = Entities:FindByName(nil, "dire_path_start")
    Spawners.h_DireInit_Mid_AltA            = Entities:FindByName(nil, "dire_path_mid_1a")
    Spawners.h_DireInit_Mid_AltB            = Entities:FindByName(nil, "dire_path_mid_1b")
    Spawners.h_DireInit_Bot                 = Entities:FindByName(nil, "dire_path_bot_1")
    Spawners.h_DireInit_ShelfTop            = Entities:FindByName(nil, "dire_path_shelf_top1")
    Spawners.h_DireInit_ShelfBot            = Entities:FindByName(nil, "dire_path_shelf_bot1")

    -- Round 4 Spawners 
    Spawners.h_Round4_Radi                  = Entities:FindByName(nil, "spawner_round4_radi")
    Spawners.h_Round4_Dire                  = Entities:FindByName(nil, "spawner_round4_dire")
    Spawners.h_Waypoint_Radi_Ancient        = Entities:FindByName(nil, "dire_path_end")
    Spawners.h_Waypoint_Dire_Ancient        = Entities:FindByName(nil, "radiant_path_end")

    -- Create Spawn Configs to Loop Through
    -- Key = Location; Value = {Spawner, FirstWaypoint, MeleeCreepToUse, RangedCreepToUse, Siege, Team}
    -- we can then loop through these to spawn on spawn intervals
    -- but they can be updated in other places (e.g. on rax death to change the creep to super/mega)
    -- start the alt routes spawners as nil so they don't spawn until at 10 min they get forced to start up
    Spawners.SpawnConfigs = {}
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_TOP]        = {Spawner = self.h_RadiantSpawn_Top,       FirstWaypoint = self.h_RadiantInit_Top,      Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_MIDA]       = {Spawner = self.h_RadiantSpawn_Mid_A,     FirstWaypoint = self.h_RadiantInit_Mid_Main, Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_MIDB]       = {Spawner = nil,                           FirstWaypoint = self.h_RadiantInit_Mid_AltB, Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_BOT]        = {Spawner = self.h_RadiantSpawn_Bot,       FirstWaypoint = self.h_RadiantInit_Bot,      Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_SHELFTOP]   = {Spawner = self.h_RadiantSpawn_ShelfTop,  FirstWaypoint = self.h_RadiantInit_ShelfTop, Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }
    Spawners.SpawnConfigs[Constants.KEY_RADIANT_SHELFBOT]   = {Spawner = self.h_RadiantSpawn_ShelfBot,  FirstWaypoint = self.h_RadiantInit_ShelfBot, Melee = "npc_avalore_creep_melee_radi", Ranged = "npc_avalore_creep_ranged_radi", Siege = "npc_avalore_siege_radi", Team = DOTA_TEAM_GOODGUYS }

    Spawners.SpawnConfigs[Constants.KEY_DIRE_TOP]           = {Spawner = self.h_DireSpawn_Top,          FirstWaypoint = self.h_DireInit_Top,        Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs[Constants.KEY_DIRE_MIDA]          = {Spawner = self.h_DireSpawn_Mid_A,        FirstWaypoint = self.h_DireInit_Mid_Main,   Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs[Constants.KEY_DIRE_MIDB]          = {Spawner = nil,                           FirstWaypoint = self.h_DireInit_Mid_AltB,   Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs[Constants.KEY_DIRE_BOT]           = {Spawner = self.h_DireSpawn_Bot,          FirstWaypoint = self.h_DireInit_Bot,        Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs[Constants.KEY_DIRE_SHELFTOP]      = {Spawner = self.h_DireSpawn_ShelfTop,     FirstWaypoint = self.h_DireInit_ShelfTop,   Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }
    Spawners.SpawnConfigs[Constants.KEY_DIRE_SHELFBOT]      = {Spawner = self.h_DireSpawn_ShelfBot,     FirstWaypoint = self.h_DireInit_ShelfBot,   Melee = "npc_avalore_creep_melee_dire",   Ranged = "npc_avalore_creep_ranged_dire",  Siege = "npc_avalore_siege_dire", Team = DOTA_TEAM_BADGUYS }

    Spawners.MercQueue = {}
    Spawners.MercQueue[DOTA_TEAM_GOODGUYS] = {}
    Spawners.MercQueue[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_TOP] = {}
    Spawners.MercQueue[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_BOT] = {}
    Spawners.MercQueue[DOTA_TEAM_BADGUYS] = {}
    Spawners.MercQueue[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_TOP] = {}
    Spawners.MercQueue[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_BOT] = {}

    DemiHeroManager:AddTeam(DOTA_TEAM_GOODGUYS)
    DemiHeroManager:AddTeam(DOTA_TEAM_BADGUYS)

    print("Spawning Merc Camps")
    Spawners.MercCamps = {}
    Spawners.MercCamps[DOTA_TEAM_GOODGUYS] = {}
    Spawners.MercCamps[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_TOP] = CreateUnitByName( "mercenary_camp", Vector(-7232, -5888, 256), true, nil, nil, DOTA_TEAM_GOODGUYS )
    -- no rotation needed here
    Spawners.MercCamps[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_BOT] = CreateUnitByName( "mercenary_camp", Vector(-5888, -7232, 256), true, nil, nil, DOTA_TEAM_GOODGUYS )
    Spawners.MercCamps[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_BOT]:SetForwardVector(Vector(0,1,0)) -- face towards top of map
    for key, value in pairs(Spawners.MercCamps[DOTA_TEAM_GOODGUYS]) do
        value:AddNewModifier(value, nil, "modifier_shows_through_fog", {})
        -- local merc_item = value:AddItemByName("item_merc_demi_hero_yeti")
        -- merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        local merc_item = value:AddItemByName("item_merc_super_djinn")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        merc_item = value:AddItemByName("item_merc_skeletons")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        merc_item = value:AddItemByName("item_merc_pyromancer")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
    end
    Spawners.MercCamps[DOTA_TEAM_BADGUYS] = {}
    Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_BOT] = CreateUnitByName( "mercenary_camp", Vector(7232, 5888, 256), true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_BOT]:SetForwardVector(Vector(-1,0,0)) -- face bottom of map
    Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_TOP] = CreateUnitByName( "mercenary_camp", Vector(5888, 7232, 256), true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_TOP]:SetForwardVector(Vector(0,-1,0)) -- face the left of the map
    for key, value in pairs(Spawners.MercCamps[DOTA_TEAM_BADGUYS]) do
        value:AddNewModifier(value, nil, "modifier_shows_through_fog", {})
        -- local merc_item = value:AddItemByName("item_merc_demi_hero_yeti")
        -- merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        local merc_item = value:AddItemByName("item_merc_super_djinn")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        merc_item = value:AddItemByName("item_merc_skeletons")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
        merc_item = value:AddItemByName("item_merc_pyromancer")
        merc_item:SetShareability(ITEM_FULLY_SHAREABLE) -- fully shareable
    end


    --self:InitFlags()
    print("Spawners Initialized")
end

function Spawners:InitFlags()
    -- Setup Flag Bases
    Spawners.RadiFlagBases = {}
    Spawners.RadiFlagBases.Top  = CreateUnitByName( "npc_avalore_radi_flag_base", Entities:FindByName(nil, "spawner_radi_top_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_GOODGUYS )
    Spawners.RadiFlagBases.Mid  = CreateUnitByName( "npc_avalore_radi_flag_base", Entities:FindByName(nil, "spawner_radi_mid_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_GOODGUYS )
    Spawners.RadiFlagBases.Bot  = CreateUnitByName( "npc_avalore_radi_flag_base", Entities:FindByName(nil, "spawner_radi_bot_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_GOODGUYS )
    Spawners.RadiFlagBases.TopL = CreateUnitByName( "npc_avalore_radi_flag_base", Entities:FindByName(nil, "spawner_radi_top_low_flag"):GetOrigin(),    true, nil, nil, DOTA_TEAM_GOODGUYS )
    Spawners.RadiFlagBases.BotL = CreateUnitByName( "npc_avalore_radi_flag_base", Entities:FindByName(nil, "spawner_radi_bot_low_flag"):GetOrigin(),    true, nil, nil, DOTA_TEAM_GOODGUYS )

    Spawners.DireFlagBases = {}
    Spawners.DireFlagBases.Top  = CreateUnitByName( "npc_avalore_dire_flag_base", Entities:FindByName(nil, "spawner_dire_top_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.DireFlagBases.Mid  = CreateUnitByName( "npc_avalore_dire_flag_base", Entities:FindByName(nil, "spawner_dire_mid_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.DireFlagBases.Bot  = CreateUnitByName( "npc_avalore_dire_flag_base", Entities:FindByName(nil, "spawner_dire_bot_flag"):GetOrigin(),        true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.DireFlagBases.TopL = CreateUnitByName( "npc_avalore_dire_flag_base", Entities:FindByName(nil, "spawner_dire_top_low_flag"):GetOrigin(),    true, nil, nil, DOTA_TEAM_BADGUYS )
    Spawners.DireFlagBases.BotL = CreateUnitByName( "npc_avalore_dire_flag_base", Entities:FindByName(nil, "spawner_dire_bot_low_flag"):GetOrigin(),    true, nil, nil, DOTA_TEAM_BADGUYS )
    
    --print("TopL = " .. tostring(Spawners.RadiFlagBases.TopL:GetOrigin()))

    --print("model = " .. Entities:FindByName(nil, "radiant_outpost_trigger"):GetModelName())
    
    for key, value in pairs(Spawners.RadiFlagBases) do
        -- Make the flag bases invincible and not show health bars
        value:AddNewModifier(value, nil, "modifier_flagbase", {})
        value:AddNewModifier(value, nil, "modifier_no_healthbar", {})
        --local hFlagTrigger = CreateTrigger(value:GetBoundingMins(), value:GetBoundingMaxs())
        --local vPos = 
        --local hFlagTrigger = CreateTriggerRadiusApproximate(value:GetOrigin(), 200)
        --local hFlagTrigger = SpawnEntityFromTableSynchronous("trigger_dota", {origin = (value:GetOrigin() + Vector(0, 0, 64)), model = Entities:FindByName(nil, "radiant_outpost_trigger"):GetModelName()})
        --hFlagTrigger:SetEntityName(("trigger_Radi_Flag_" .. key))
        --hFlagTrigger.OnStartTouch = FlagTrigger_OnStartTouch
        --hFlagTrigger:RedirectOutput("OnStartTouch", "OnStartTouch", hFlagTrigger)
        --hFlagTrigger:Enable()
        --hFlagTrigger:Enable()
        --print(hFlagTrigger:GetName() .. " is at Origin: " .. tostring(hFlagTrigger:GetOrigin()) .. " || ABS Origin = " .. tostring(hFlagTrigger:GetAbsOrigin()) .. " || Max Bound = " .. tostring(hFlagTrigger:GetBoundingMaxs()) .. " || Min Bound = " .. tostring(hFlagTrigger:GetBoundingMins()))
        --value:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, 0.1)
    end
    for key, value in pairs(Spawners.DireFlagBases) do
        -- Make the flag bases invincible and not show health bars
        value:AddNewModifier(value, nil, "modifier_flagbase", {})
        value:AddNewModifier(value, nil, "modifier_no_healthbar", {})
        --value:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, 0.1)
    end
    print("Flags Bases Initialized")
    --local test = Entities:FindByName(nil, "trigger_Radi_Flag_TopL")
    --print(test:GetName() .. " is at Origin: " .. tostring(test:GetOrigin()) .. " || ABS Origin = " .. tostring(test:GetAbsOrigin()) .. " || Max Bound = " .. tostring(test:GetBoundingMaxs()) .. " || Min Bound = " .. tostring(test:GetBoundingMins()))

    -- Spawn Actual Flags

    local newItem           = CreateItem( OBJECTIVE_FLAG_ITEM_A, nil , nil )
    -- for the flag particles to init
    local spawner_tmp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_A)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    local newItemPhysical   = CreateItemOnPositionSync( Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_A):GetOrigin(), newItem )
    --newItemPhysical:SetRenderColor(245, 166, 35)
    --newItemPhysical:SetForwardVector(Vector(0,-1,0))
    RenderFlagMorale(newItemPhysical)
    SetFlagForward(newItemPhysical)

    newItem           = CreateItem( OBJECTIVE_FLAG_ITEM_B, nil , nil )
    -- for the flag particles to init
    spawner_tmp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_B)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    newItemPhysical   = CreateItemOnPositionSync( Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_B):GetOrigin(), newItem )
    -- newItemPhysical:SetRenderColor(245, 166, 35)
    -- newItemPhysical:SetForwardVector(Vector(0,-1,0))
    RenderFlagMorale(newItemPhysical)
    SetFlagForward(newItemPhysical)

    newItem           = CreateItem( OBJECTIVE_FLAG_ITEM_C, nil , nil )
    -- for the flag particles to init
    spawner_tmp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_C)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    newItemPhysical   = CreateItemOnPositionSync( Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_C):GetOrigin(), newItem )
    -- newItemPhysical:SetRenderColor(126, 211, 33)
    -- newItemPhysical:SetForwardVector(Vector(0,-1,0))
    RenderFlagAgility(newItemPhysical)
    SetFlagForward(newItemPhysical)

    newItem           = CreateItem( OBJECTIVE_FLAG_ITEM_D, nil , nil )
    -- for the flag particles to init
    spawner_tmp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_D)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    newItemPhysical   = CreateItemOnPositionSync( Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_D):GetOrigin(), newItem )
    --newItemPhysical:GetRenderColor(OBJECTIVE_FLAG_RENDER_D[0], OBJECTIVE_FLAG_RENDER_D[1], OBJECTIVE_FLAG_RENDER_D[2])
    --newItemPhysical:SetRenderColor(148,0,211)
    -- newItemPhysical:SetRenderColor(72, 186, 255)
    -- newItemPhysical:SetForwardVector(Vector(0,-1,0))
    RenderFlagArcane(newItemPhysical)
    SetFlagForward(newItemPhysical)

    newItem           = CreateItem( OBJECTIVE_FLAG_ITEM_E, nil , nil )
    -- for the flag particles to init
    spawner_tmp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_E)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, spawner_tmp:GetAbsOrigin(), 200, 10.0, false)
    newItemPhysical   = CreateItemOnPositionSync( Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_E):GetOrigin(), newItem )
    -- newItemPhysical:SetRenderColor(65, 116, 5)
    -- newItemPhysical:SetForwardVector(Vector(0,-1,0))
    RenderFlagRegrowth(newItemPhysical)
    SetFlagForward(newItemPhysical)

    --print("Top has " .. Spawners.DireFlagBases.Top:GetModifierCount() .. " modifiers.")
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
        Every 2 min (starting on min 2):
        * spawner_good_shelf_top ==> radiant_path_shelf_top1 ==> radiant_path_shelf_top2 ==> radiant_path_shelf_top3 ==> radiant_path_end
        * spawner_good_shelf_bot ==> radiant_path_shelf_bot1 ==> radiant_path_shelf_bot2 ==> radiant_path_shelf_bot3 ==> radiant_path_end
    DIRE
        * spawner_bad_top ==> dire_path_top_1 ==> dire_path_top_2 ==> dire_path_end
        * spawner_bad_bot ==> dire_path_bot_1 ==> dire_path_bot_2 ==> dire_path_end
        Min 0-10:
        * spawner_bad_mid ==> dire_path_start ==> dire_path_mid_1 ==> dire_path_end
        Min 10+:
        * spawner_bad_mid ==> dire_path_mid_1a ==> dire_path_mid_right1 => dire_path_mid_right2 => dire_path_mid_right3 => dire_path_mid_recombine ==> dire_path_end
        * spawner_bad_midb => dire_path_mid_1b ==> dire_path_mid_left1 ==> dire_path_mid_left2 ==> dire_path_mid_left3 ==> dire_path_mid_recombine ==> dire_path_end
        Every 2 min (starting on min 2):
        * spawner_bad_shelf_top ==> dire_path_shelf_top1 ==> dire_path_shelf_top2 ==> dire_path_shelf_top3 ==> dire_path_end
        * spawner_bad_shelf_bot ==> dire_path_shelf_bot1 ==> dire_path_shelf_bot2 ==> dire_path_shelf_bot3 ==> dire_path_end

    NOTE: Spawner and first waypoint are controlled programmatically, the rest is done via the entities on the map itself
--]]

function Spawners:DetermineNumMeleeToSpawn(iGameTimeSeconds, sLaneKey)
    local iNum = 0
    if iGameTimeSeconds < Constants.TIME_ROUND_2_START then
        iNum = 3
    elseif iGameTimeSeconds < Constants.TIME_ROUND_3_START then
        iNum = 4
    elseif iGameTimeSeconds < Constants.TIME_ROUND_4_START then
        iNum = 5
    else
        iNum = 6
    end

    -- once the lanes start splitting, we don't need to send as many creeps or there will be
    -- way too much XP on the map
    if (iGameTimeSeconds > self.iSplitTime and string.find(sLaneKey, "Mid")) or string.find(sLaneKey, "Shelf") then 
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

    if string.find(sLaneKey, "Shelf") then
        iNum = iNum + 1
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
    self.SpawnConfigs[Constants.KEY_RADIANT_MIDA].FirstWaypoint = self.h_RadiantInit_Mid_AltA

    self.SpawnConfigs[Constants.KEY_RADIANT_MIDB].Spawner       = self.h_RadiantSpawn_Mid_B
    self.SpawnConfigs[Constants.KEY_RADIANT_MIDB].FirstWaypoint = self.h_RadiantInit_Mid_AltB

    self.SpawnConfigs[Constants.KEY_DIRE_MIDA].FirstWaypoint    = self.h_DireInit_Mid_AltA

    self.SpawnConfigs[Constants.KEY_DIRE_MIDB].Spawner          = self.h_DireSpawn_Mid_B
    self.SpawnConfigs[Constants.KEY_DIRE_MIDB].FirstWaypoint    = self.h_DireInit_Mid_AltB
end

-- Loop through the spawn configs and create the creep waves
function Spawners:SpawnLaneCreeps(iGameTimeSeconds)
    --print("GameTime = " .. tostring(iGameTimeSeconds) .. ", \tEval = " .. tostring(math.floor(iGameTimeSeconds) % 30))
    print("Start Spawning Waves...")
    if (not Spawners.lanesAreSplit) and (iGameTimeSeconds > self.iSplitTime) then
        self:SplitLanes()
    end

    -- send shelf wave every 2 min starting on min 2
    local bSendShelf = false
    if iGameTimeSeconds > 1 and iGameTimeSeconds % Spawners.iShelfInterval == 0 then
        bSendShelf = true
    end

    for key,value in pairs(self.SpawnConfigs) do
        if value.Spawner ~= nil then
            --print("Spawning for key " .. key .. " \t\t| At Spawner: " .. value.Spawner:GetName() .. " \t\t| With Goal: " .. value.FirstWaypoint:GetName())
            if (not string.find(key, "Shelf")) or bSendShelf then
                -- spawn melee creeps
                for i = 1, self:DetermineNumMeleeToSpawn(iGameTimeSeconds, key), 1 do
                    --local creep_ver = self:GetCreepVersionSuffix("melee", value.Team, key)
                    local creep = CreateUnitByName( value.Melee, value.Spawner:GetOrigin(), true, nil, nil, value.Team )
                    -- if value.Team == DOTA_TEAM_GOODGUYS then
                    --     creep:SetModel("models/creeps/lane_creeps/creep_radiant_melee/radiant_melee.vmdl")
                    -- end
                    creep:SetInitialGoalEntity(value.FirstWaypoint)
                end

                -- spawn ranged creeps
                for i = 1, self:DetermineNumRangedToSpawn(iGameTimeSeconds, key), 1 do
                    local creep = CreateUnitByName( value.Ranged, value.Spawner:GetOrigin(), true, nil, nil, value.Team )
                    creep:SetInitialGoalEntity(value.FirstWaypoint)
                end

                -- spawn mercs
                local merc_queue = Spawners.MercQueue[value.Team][key]
                if merc_queue then 
                    --print("Looping over MercQueue for " .. tostring(key))
                    while table.getn(merc_queue) > 0 do
                        local merc_unit = table.remove(merc_queue)
                        --print("Popped off unit in queue: " .. merc_unit)
                        local creep = CreateUnitByName( merc_unit, value.Spawner:GetOrigin(), true, nil, nil, value.Team )
                        creep:SetInitialGoalEntity(value.FirstWaypoint)
                        -- for demi heroes, init level
                        print("creep:GetName() ==> " .. creep:GetName())
                        print("creep:GetUnitLabel() ==> " .. creep:GetUnitLabel())
                        print("creep:GetUnitName() ==> " .. creep:GetUnitName())
                        if string.find(creep:GetUnitName(), "demi_hero") then
                            print("Leveling up Demi-Hero to " .. tostring(DemiHeroManager:GetDemiHeroLevel(value.Team, creep:GetUnitName())))
                            creep:CreatureLevelUp(DemiHeroManager:GetDemiHeroLevel(value.Team, creep:GetUnitName()) - 1)
                            --creep:SetLevel(DemiHeroManager:GetDemiHeroLevel(value.Team, creep:GetUnitName()))
                        end
                    end
                    local queue_obj = {loc = key};
                    --print("Clearing Hire Queue " .. key)
                    CustomGameEventManager:Send_ServerToTeam(value.Team, "clear_hire_queue", queue_obj)
                end

            end
        end
    end

    --print("Round = " .. tostring(_G.round) .. " || Boss value = " .. tostring(Score.round4.boss))
    if _G.round == 4 and Score.round4.boss == nil then
        --print("[Spawners] spawning neutral wave")
        for i = 1, 13, 1 do
            -- radiant attackers
            local creep = CreateUnitByName( ROUND4_MELEE_CREEPS, Spawners.h_Round4_Radi:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_CUSTOM_1 )
            creep:SetInitialGoalEntity(Spawners.h_Waypoint_Radi_Ancient)
            creep:SetRequiresReachingEndPath(true)
            creep:MoveToPositionAggressive(Spawners.h_Waypoint_Radi_Ancient:GetAbsOrigin())
            -- dire attackers
            creep = CreateUnitByName( ROUND4_MELEE_CREEPS, Spawners.h_Round4_Dire:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_CUSTOM_1 )
            creep:SetInitialGoalEntity(Spawners.h_Waypoint_Dire_Ancient)
            creep:SetRequiresReachingEndPath(true)
            creep:MoveToPositionAggressive(Spawners.h_Waypoint_Dire_Ancient:GetAbsOrigin())
        end 
    end
    --print("End Spawning Waves...")
end

-- ========================================================
-- Deteremines which suffix "_super", "_mega" to append
-- to fetch the right lane creep to spawn.
-- Super = when you kill the other team's rax (both req
--         for siege)
-- Mega = when you kill ALL the other team's raxes
-- Note: Shelf creeps are tethered to the adjacent Top/Bot
--       rax.
-- ========================================================
-- creep_type: melee/ranged/siege
-- team: DOTA_TEAM_GOODGUYS/DOTA_TEAM_BADGUYS
-- lane: KEY_RADIANT_TOP, KEY_RADIANT_BOT, etc.
-- ========================================================
-- Spawners:GetCreepVersionSuffix(creep_type, team, lane)
--     local return_suffix = ""
--     local opposingTeam = ""
--     if team == DOTA_TEAM_BADGUYS then
--         opposingTeam = DOTA_TEAM_GOODGUYS
--     else
--         opposingTeam = DOTA_TEAM_BADGUYS
--     end

--     lane_id = BuildingLaneLocation(string.lower(lane))

--     -- check super
--     if creep_type ~= "siege" then
--         if not Score.raxes[opposingTeam][lane_id][creep_type] then
--             return_suffix = "_super"
--         end
--     else
--         if (not Score.raxes[opposingTeam][lane_id]["melee"]) and (not not Score.raxes[opposingTeam][lane_id]["melee"])
--             return_suffix = "_super"
--         end
--     end

--     -- if we're super, check for mega
--     if return_suffix == "_super" then

-- ========================================================
-- Appends suffix "_super" to lane
-- Super = when you kill the other team's rax (both req
--         for siege)
-- Mega = when you kill ALL the other team's raxes
-- Note: Shelf creeps are tethered to the adjacent Top/Bot
--       rax.
-- ========================================================
-- creep_type: Melee/Ranged/Siege
-- team: DOTA_TEAM_GOODGUYS/DOTA_TEAM_BADGUYS
-- lane: KEY_RADIANT_TOP, KEY_RADIANT_BOT, etc.
-- ========================================================
function Spawners:UpgradeToSuper(team, lane_id, creep_type)
    local team_name = "Radiant"
    if team == DOTA_TEAM_BADGUYS then
        team_name = "Dire"
    end

    local configs = {}

    print("Upgrading " .. team_name .. lane_id .. " lane creeps to Super")

    if lane_id == "top" then
        configs = {team_name .. "_Top", team_name .. "_ShelfTop"}
    elseif lane_id == "bot" then 
        configs = {team_name .. "_Bot", team_name .. "_ShelfBot"}
    elseif lane_id == "mid" then
        configs = {team_name .. "_MidA", team_name .. "_MidB"}
        -- -- if lanes have already been split, we need to also update those
        -- if Spawners.SpawnConfigs[team_name .. "_MidB"].Spawner then
        --     table.insert(configs, team_name .. "_MidB")
        -- end
    end

    
    for key, value in pairs(configs) do
        Spawners.SpawnConfigs[value][creep_type] = (Spawners.SpawnConfigs[value][creep_type] .. "_super")
    end
end

function Spawners:UpgradeToMega(team)
    local team_name = "Radiant"
    if team == DOTA_TEAM_BADGUYS then
        team_name = "Dire"
    end

    print("Upgrading " .. team_name .. " creeps to Mega")

    local creep_types = {"Melee", "Ranged", "Siege"}

    local configs = {team_name .. "_Top", team_name .. "_ShelfTop", team_name .. "_Bot", team_name .. "_ShelfBot", team_name .. "_MidA", team_name .. "_MidB"}
    for key, lane_config in pairs(configs) do
        for key2, creep_type in pairs(creep_types) do
            Spawners.SpawnConfigs[lane_config][creep_type] = (Spawners.SpawnConfigs[lane_config][creep_type] .. "_mega")
        end
    end
end