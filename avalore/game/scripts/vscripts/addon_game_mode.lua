--[[
Avalore Game Mode
]]

_G.nCOUNTDOWNTIMER = 2401
_G.Temp = false
_G.round = 0
_G.first_loop = true
_G.time_offset = 0
_G.round_1_init = false
--[[
_G.GoodScore = 0
_G.BadScore = 0

radi_outpost = nil
t_radi_outpost = {}
t_radi_outpost.radiTime = 0
t_radi_outpost.direTime = 0
dire_outpost = nil
t_dire_outpost = {}
t_dire_outpost.radiTime = 0
t_dire_outpost.direTime = 0
--]]

---------------------------------------------------------------------------
-- CAvaloreGameMode class
---------------------------------------------------------------------------

if CAvaloreGameMode == nil then
	_G.CAvaloreGameMode = class({})
end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
require( "events" )
--require( "items" )
require( "utility_functions" )
require( "spawners" )
require ("constants")
require("score")
require("references")
require('libraries/player')
require("libraries/vector_target")
require('buildings/hire_queue')
require("avalore_debug")
require('hero_extension')
require('addon_init') -- client-side code/extension
require('filters')

flag_announce_curr = 1

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	PrecacheResource( "model", OBJECTIVE_FLAG_MODEL_A, context )
	PrecacheResource( "model", OBJECTIVE_FLAG_MODEL_B, context )
	PrecacheResource( "model", OBJECTIVE_FLAG_MODEL_C, context )
	PrecacheResource( "model", OBJECTIVE_FLAG_MODEL_D, context )
	PrecacheResource( "model", OBJECTIVE_FLAG_MODEL_E, context )

	LinkLuaModifier( "modifier_unselectable", MODIFIER_UNSELECTABLE, LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_capturable", MODIFIER_CAPTURABLE, LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_invuln_tower_based", MODIFIER_INVULN_TOWER_BASED, LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_wearable", "scripts/vscripts/modifiers/modifier_wearable", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_knockback", "scripts/vscripts/modifiers/modifier_knockback.lua", LUA_MODIFIER_MOTION_BOTH )
end

-- Create the game mode when we activate
function Activate()
	CAvaloreGameMode:InitGameMode()
end

---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function CAvaloreGameMode:InitGameMode()
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CAvaloreGameMode, "OnEntityKilled"), self)

	ListenToGameEvent("dota_on_hero_finish_spawn", Dynamic_Wrap(CAvaloreGameMode, "OnHeroFinishSpawn"), self)

	-- ITEM STUFF (see: inventory_manager.lua and inventory.lua)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(CAvaloreGameMode, "OnItemPickUp"), self)
	ListenToGameEvent("dota_inventory_item_added", Dynamic_Wrap(CAvaloreGameMode, "OnItemAdded"), self)
	ListenToGameEvent("dota_hero_inventory_item_change", Dynamic_Wrap(CAvaloreGameMode, "OnInventoryChanged"), self)
	ListenToGameEvent("dota_courier_transfer_item", Dynamic_Wrap(CAvaloreGameMode, "TransferItem"), self)
	ListenToGameEvent("dota_action_item", Dynamic_Wrap(CAvaloreGameMode, "ActionItem"), self)
	ListenToGameEvent("dota_inventory_player_got_item", Dynamic_Wrap(CAvaloreGameMode, "PlayerGotItem"), self)
	ListenToGameEvent("dota_item_drag_begin", Dynamic_Wrap(CAvaloreGameMode, "ItemDragBegin"), self)
	ListenToGameEvent("dota_item_drag_end", Dynamic_Wrap(CAvaloreGameMode, "ItemDragEnd"), self)
	ListenToGameEvent("inventory_updated", Dynamic_Wrap(CAvaloreGameMode, "InventoryUpdated"), self)
	ListenToGameEvent("dota_inventory_item_changed", Dynamic_Wrap(CAvaloreGameMode, "InventoryItemChanged"), self)
	ListenToGameEvent("dota_item_combined", Dynamic_Wrap(CAvaloreGameMode, "ItemCombined"), self)
	ListenToGameEvent("dota_inventory_changed", Dynamic_Wrap(CAvaloreGameMode, "InventoryChanged"), self)
	ListenToGameEvent("dota_inventory_changed_query_unit", Dynamic_Wrap(CAvaloreGameMode, "InventoryChangedQueryUnit"), self)
	ListenToGameEvent("dota_item_gifted", Dynamic_Wrap(CAvaloreGameMode, "ItemGifted"), self)
	ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(CAvaloreGameMode, "ItemPurchased"), self)
	
	-- PLAYER CHAT (see avalore_debug.lua)
	ListenToGameEvent("player_chat", Dynamic_Wrap(CAvaloreGameMode, "ProcessPlayerMessage"), self)

	-- ABILITIES & TALENTS
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(CAvaloreGameMode, 'OnPlayerLearnedAbility'), self)

	--ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CAvaloreGameMode, "OnPlayerFirstSpawn"), self)
	-- ListenToGameEvent("dota_inventory_item_changed", Dynamic_Wrap(CAvaloreGameMode, "OnItemSlotChanged"), self)
	-- ListenToGameEvent("inventory_updated", Dynamic_Wrap(CAvaloreGameMode, "OnInventoryUpdated"), self)
	-- ListenToGameEvent("dota_item_gifted", Dynamic_Wrap(CAvaloreGameMode, "OnItemGifted"), self)
	-- ListenToGameEvent("dota_inventory_changed", Dynamic_Wrap(CAvaloreGameMode, "OnInventoryChanged"), self)
	ListenToGameEvent( "dota_item_spawned", Dynamic_Wrap( CAvaloreGameMode, "OnItemSpawned" ), self )
	_G.nCOUNTDOWNTIMER = 2401
	self.countdownEnabled = true
	GameRules:SetPreGameTime( 10 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:GetGameModeEntity():SetCustomBackpackCooldownPercent(1.0) -- no punishment
	GameRules:GetGameModeEntity():SetCustomBackpackSwapCooldown(0.0) -- no cooldown

	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CAvaloreGameMode, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(CAvaloreGameMode, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(CAvaloreGameMode, "AbilityTuningFilter"), self)
	
	-- Custom Mode Framework Inits
	Spawners:Init()
	Score:Init()
	-- set unselectable so they can't be captured until round2 begins
	-- also note: force set the team to NOTEAM later on or the engine forces 
	--            them to begin as radiant and dire owned
	Score.entities.radi_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})
	Score.entities.dire_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})

	-- Spawn Merc Camps
	--local merc_camp = CreateUnitByName( "mercenary_camp", Vector(-7232, -5888, 256), true, nil, nil, DOTA_TEAM_GOODGUYS )
	
	--merc_camp:SetForwardVector(Vector(-1, 0, 0)) -- have door face right
	--local ancient_r = Entities:FindByName(nil, "npc_dota_goodguys_fort")
	--print("Ancient's owner " .. ancient_r:GetOwnerEntity():)

	--PlayerResource:SetUnitShareMaskForPlayer(nPlayerID, nOtherPlayerID, nFlag, bState)

	-- local merc_camp = CreateUnitByName( "mercenary_camp", Vector(-7232, -5888, 256), true, nil, PlayerResource:GetPlayer(0), DOTA_TEAM_GOODGUYS )
	-- merc_camp:SetOwner(PlayerResource:GetPlayer(0))
	-- merc_camp:SetControllableByPlayer(0, false)
	-- merc_camp.lane = Constants.KEY_RADIANT_TOP
	--merc_camp:IsSharedWithTeammates

	-- for playerID = 0, DOTA_MAX_PLAYERS do
    --     if PlayerResource:IsValidPlayerID(playerID) then
    --         if not PlayerResource:IsBroadcaster(playerID) then
	-- 			local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
    --             if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
	-- 				print("Sharing with playerID " .. tostring(playerID))
	-- 				merc_camp:SetControllableByPlayer(playerID, true)
	-- 			end
	-- 		end
	-- 	end
	-- end

	--[[local score_obj = 
	{
		radi_score = 0,
		dire_score = 0
	}
	CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )
	--]]
end

-- function CAvaloreGameMode:OnAllPlayersLoaded()
	
-- end

local temp = false

-- Evaluate the state of the game
function CAvaloreGameMode:OnThink()

	--grab current time as a float, excluding pregame and negative time
	curr_gametime = GameRules:GetDOTATime(false, false)
	curr_gametime = curr_gametime + _G.time_offset

	-- if self.countdownEnabled == true then
	-- 	CountdownTimer()
	-- 	--_G.nCOUNTDOWNTIMER = _G.nCOUNTDOWNTIMER - 1;
	-- 	--print("Countdown = " .. tostring(_G.nCOUNTDOWNTIMER))
	-- end

	-- spawn rosh and blockers after wave finishes splitting (DOES NOT WORK)
	-- if math.floor(curr_gametime)  == 30 then --Constants.TIME_ROUND_2_START then --+ 60 then
	-- 	print("-----Making blockers------")
	-- 	local tFowBlockerSpawns = Entities:FindAllByName("spawner_fow_blocker")
	-- 	local hFowBlocker = nil
	-- 	for key,value in pairs(tFowBlockerSpawns) do
	-- 		--hFowBlocker = Entities:CreateByClassname("ent_fow_blocker_node")
	-- 		--hFowBlocker:SetOrigin(value:GetOrigin())
	-- 		hFowBlocker = SpawnEntityFromTableSynchronous("ent_fow_blocker_node", {origin = value:GetOrigin()})
	-- 		--print("Spawner at " .. tostring(value:GetOrigin()) .. " || blocker at " .. tostring(hFowBlocker:GetOrigin()))
	-- 	end
		
	-- end


	if curr_gametime > Constants.TIME_ROUND_4_START then
		if(_G.round < 4) then
			print("Round 4 Start - Waves")
			_G.round = 4
			self:InitRound4()
		end
	elseif curr_gametime > Constants.TIME_ROUND_3_START then
		if(_G.round < 3) then
			print("Round 3 Start - Boss")
			_G.round = 3
			self:InitRound3()
		end
	elseif curr_gametime > Constants.TIME_ROUND_2_START then 
		if(_G.round < 2) then
			print("Round 2 Start - King of the Hill")
			_G.round = 2
			self:InitRound2()
		end
		-- spawn boss after creeps have had a minute to finish splitting
		if math.floor(curr_gametime)  == (Constants.TIME_ROUND_2_START + 60) then
			CreateUnitByName( "npc_dota_roshan", Entities:FindByName(nil, "spawner_map_center"):GetOrigin(),        true, nil, nil, DOTA_TEAM_NEUTRALS )
		end

		Score:UpdateRound2()
		if math.floor(curr_gametime) % 10 == 0 then
			Score:DebugRound2()
		end
	elseif curr_gametime > 0 then
		--temp debug
		--print("Hero At: " .. tostring(PlayerResource:GetSelectedHeroEntity(0):GetOrigin()))
		--print("Touching TopL? " .. tostring(Entities:FindByName(nil, "trigger_Radi_Flag_TopL"):IsTouching(PlayerResource:GetSelectedHeroEntity(0))))
		
		-- First pass through round events
		if(_G.round < 1) then
			print("Round 1 Start - Wisps")
			_G.round = 1
			self:InitRound1()
		end
		-- spawn flags ping notification
		if (flag_announce_curr == 1) then
			Spawners:InitFlags()
		end
		if (flag_announce_curr < 6) then 
			local flag_temp
			--print("Trying to ping flag locations")
			for playerId = 0,19 do
				local player = PlayerResource:GetPlayer(playerId)
				if player ~= nil then
					if player:GetAssignedHero() then
						if (player:GetTeam() == DOTA_TEAM_GOODGUYS) or (player:GetTeam() == DOTA_TEAM_BADGUYS) then
							flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNERS[flag_announce_curr])
							print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
							MinimapEvent( player:GetTeam(), player:GetAssignedHero(), flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
						end
					end
				end
			end
			flag_announce_curr = flag_announce_curr + 1
		end
	elseif curr_gametime == 0 and _G.first_loop then
		self.GameStartInit()
		_G.first_loop = false
	end
	--10 sec warning
	if(curr_gametime > 0) then
		local time_in_curr_round = curr_gametime - ((_G.round - 1) * 600)
		--print("Time in Curr Round = " .. tostring(time_in_curr_round))
		if (time_in_curr_round < 11) then
			--CountdownTimer(math.floor(time_in_curr_round))
		end
	end

	-- --TEMP ==> force debug: set hero to lvl 6
	-- local p1_hero = PlayerResource:GetSelectedHeroEntity(0)
	-- -- if p1_hero then
	-- -- 	print("Mana Regen = " .. tostring(p1_hero:GetManaRegen()))
	-- -- end
	-- --if p1_hero ~= nil and p1_hero:GetLevel() < 6 then
	-- if p1_hero ~= nil and p1_hero:GetLevel() < 20 then
	-- 	p1_hero:HeroLevelUp(false)
	-- 	--p1_hero:UpgradeAbility(bSupressSpeech)
	-- 	p1_hero:HeroLevelUp(false)
	-- 	p1_hero:HeroLevelUp(false)
	-- 	p1_hero:HeroLevelUp(false)
	-- 	p1_hero:HeroLevelUp(false)
	-- 	--DEBUG
	-- 	p1_hero:SetGold(10000, true)
	-- end

	-- if p1_hero and not temp then
	-- 	temp = true
	-- 	local merc_camp = CreateUnitByName( "mercenary_camp", Vector(-7232, -5888, 256), true, nil, nil, DOTA_TEAM_GOODGUYS )
	-- 	--merc_camp:SetOwner(PlayerResource:GetPlayer(0))
	-- 	merc_camp:SetTeam(DOTA_TEAM_GOODGUYS)
	-- 	merc_camp:SetControllableByPlayer(0, false)
	-- 	merc_camp.lane = Constants.KEY_RADIANT_TOP

	-- 	print(PlayerResource:GetPlayer(0):GetAssignedHero():GetEntityHandle())

	-- 	--PlayerResource:AreUnitsSharedWithPlayerID(merc_camp:GetOwnerEntity(), PlayerResource:GetPlayer(0))
	-- end

	-- Check for wave spawns on 30s intervals
	if(curr_gametime > 0 and math.floor(curr_gametime) % 30 == 0) then
		Spawners:SpawnLaneCreeps(math.floor(curr_gametime))
	end

	return 1
end -- end function: CAvaloreGameMode:OnThink()

--[[
	Certain things need to be initialized on the very first pass through the OnThink
	(e.g. outposts seem to force-set their team, even if it gets set in Init())
]]
function CAvaloreGameMode:GameStartInit()
	Score.entities.dire_outpost:SetTeam(DOTA_TEAM_NOTEAM)
	Score.entities.radi_outpost:SetTeam(DOTA_TEAM_NOTEAM)
end

-- "dota_player_pick_hero"
-- 	{
-- 		"player"	"short"	
-- 		"heroindex"	"short"
-- 		"hero"		"string"
-- 	}
-- function CAvaloreGameMode:OnPlayerFirstSpawn()
-- 	if #(Score:GetPlayerStatsTable()) == 0 then
-- 	-- 	local MercCampSpawn
-- 	-- print("Setting up Merc Camps")
-- 	-- local merc_camp = CreateUnitByName( "mercenary_camp", Vector(-7232, -5888, 256), true, nil, nil, DOTA_TEAM_GOODGUYS )
-- 	-- --merc_camp:SetOwner(PlayerResource:GetPlayer(0))
-- 	-- merc_camp:SetTeam(DOTA_TEAM_GOODGUYS)
-- 	-- merc_camp:SetControllableByPlayer(0, false)
-- 	-- merc_camp.lane = Constants.KEY_RADIANT_TOP
-- end

function CAvaloreGameMode:InitRound1()
	-- only init this once so we don't spawn a billion wisps when debugging
	if _G.round_1_init then return end

	_G.round_1_init = true
	-- spawn 7 wisps
	local wisp = nil
	local particle_fx = nil
	Score["wisps"] = {}
	for i = 0,6,1
	do
		local vSpawnLoc = nil
		while vSpawnLoc == nil do
			vSpawnLoc = Vector(0,0,0) + RandomVector(2000)
			if (GridNav:CanFindPath(Vector(0,0,0), vSpawnLoc) == false) then
				--print( "Choosing new unit spawnloc.  Bad spawnloc was: " .. tostring( vSpawnLoc ) )
				vSpawnLoc = nil
			end
		end
		wisp = CreateUnitByName( ROUND1_WISP_UNIT, vSpawnLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
		particle_fx = ParticleManager:CreateParticle("particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff_cloud.vpcf", PATTACH_POINT_FOLLOW, wisp)
		ParticleManager:SetParticleControl(particle_fx, 5, Vector(0, 0, 0))

		particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_willowisp_ambient_trail.vpcf", PATTACH_POINT_FOLLOW, wisp)
		ParticleManager:SetParticleControl(particle_fx, 5, Vector(0, 0, 0))

		particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_willowisp_ambient_sphere.vpcf", PATTACH_POINT_FOLLOW, wisp)
		ParticleManager:SetParticleControl(particle_fx, 5, Vector(0, 0, 0))
		--wisp:AddParticle(particle_fx, false, false, -1, false, false)

		wisp:StartGesture(ACT_DOTA_ATTACK)
		table.insert(Score["wisps"], wisp)
	end

	-- broadcast that round 1 has started and give some instructions
	local broadcast_obj = 
	{
		msg = "#Round1",
		time = 10,
		elaboration = "#Round1Info"
	}
	CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )

	-- -- spawn flags ping notification
	-- local flag_temp
	-- print("Trying to ping flag locations")
	-- for playerId = 0,19 do
	-- 	local player = PlayerResource:GetPlayer(playerId)
	-- 	if player ~= nil then
	-- 		if player:GetAssignedHero() then
	-- 			if (player:GetTeam() == DOTA_TEAM_GOODGUYS) or (player:GetTeam() == DOTA_TEAM_BADGUYS) then
	-- 				for i, spawner in ipairs(OBJECTIVE_FLAG_SPAWNERS) do
	-- 					flag_temp = Entities:FindByName(nil, spawner)
	-- 					print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- 					MinimapEvent( player:GetTeam(), player:GetAssignedHero(), flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- local flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_A)
	-- print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- MinimapEvent( DOTA_TEAM_GOODGUYS, flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- MinimapEvent( DOTA_TEAM_BADGUYS,  flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_B)
	-- print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- MinimapEvent( DOTA_TEAM_GOODGUYS, flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- MinimapEvent( DOTA_TEAM_BADGUYS,  flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_C)
	-- print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- MinimapEvent( DOTA_TEAM_GOODGUYS, flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- MinimapEvent( DOTA_TEAM_BADGUYS,  flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_D)
	-- print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- MinimapEvent( DOTA_TEAM_GOODGUYS, flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- MinimapEvent( DOTA_TEAM_BADGUYS,  flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
	-- flag_temp = Entities:FindByName(nil, OBJECTIVE_FLAG_SPAWNER_E)
	-- print(flag_temp:GetName() .. " | (" .. tostring(flag_temp:GetOrigin().x) .. ", " .. tostring(flag_temp:GetOrigin().y) .. ")")
	-- MinimapEvent( DOTA_TEAM_GOODGUYS, flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
    -- MinimapEvent( DOTA_TEAM_BADGUYS,  flag_temp, flag_temp:GetOrigin().x, flag_temp:GetOrigin().y, DOTA_MINIMAP_EVENT_HINT_LOCATION, 5.0 )
end

function CAvaloreGameMode:InitRound2()
	-- broadcast that round 2 has started and give some instructions
	local broadcast_obj = 
	{
		msg = "#Round2",
		time = 10,
		elaboration = "#Round2Info"
	}
	CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )
	print("clearing modifier")
	Score.entities.dire_outpost:RemoveModifierByName("modifier_unselectable")
	Score.entities.radi_outpost:RemoveModifierByName("modifier_unselectable")
	Score.entities.dire_outpost:RemoveModifierByName("modifier_invulnerable") -- modifier seems to also make uncapturable
	Score.entities.radi_outpost:RemoveModifierByName("modifier_invulnerable") -- modifier seems to also make uncapturable
	-- NOTE: Outposts have another hidden modifier: "modifier_watch_tower"

	-- kill any remaining wisps
	for _,wisp in pairs(Score["wisps"]) do
		if wisp and wisp:IsAlive() then
			wisp:ForceKill(false)
		end
	end
end

function CAvaloreGameMode:InitRound3()
	-- finish up calculations for round 2
	Score:Round2FinalTotals()
	Score:RecalculateScores()

	-- broadcast that round 3 has started and give some instructions
	local broadcast_obj = 
	{
		msg = "#Round3",
		time = 10,
		elaboration = "#Round3Info"
	}
	CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )
end

function CAvaloreGameMode:InitRound4()
	-- broadcast that round 4 has started and give some instructions
	local broadcast_obj = 
	{
		msg = "#Round4",
		time = 10,
		elaboration = "#Round4Info"
	}
	CustomGameEventManager:Send_ServerToAllClients( MESSAGE_EVENT_BROADCAST, broadcast_obj )

	-- round 3 is over, so clear up any gems around (cleanup the boss too if not beat?)
	if Score.round3.radi_gem_ref ~= nil then
		-- remove the physical container + the actual item
		local hContainer = Score.round3.radi_gem_ref:GetContainer()
		UTIL_Remove(hContainer)
		UTIL_Remove(Score.round3.radi_gem_ref)
		UTIL_Remove(Score.round3.radi_gem_drop_ref)
		print("Removing Radiant Gem")
		-- TODO: figure out how to remove the physical item if it was picked up and dropped
	end

	if Score.round3.dire_gem_ref ~= nil then
		-- remove the physical container + the actual item
		local hContainer = Score.round3.dire_gem_ref:GetContainer()
		UTIL_Remove(hContainer)
		UTIL_Remove(Score.round3.dire_gem_ref)
		UTIL_Remove(Score.round3.dire_gem_drop_ref)
		print("Removing Dire Gem")
		-- TODO: figure out how to remove the physical item if it was picked up and dropped
	end

	-- INIT Round 4 stuff
	-- create towers
	-- TODO: make sure user cannot block them from spawning, or mess with the spawn location
	for key, value in pairs(ROUND4_TOWER_TRIGGERS) do
		local tower_trigger = Entities:FindByName(nil, value)
		local tower_unit = CreateUnitByName( ROUND4_TOWER_UNIT, tower_trigger:GetOrigin(),        true, nil, nil, DOTA_TEAM_CUSTOM_1 )
		GridNav:DestroyTreesAroundPoint( tower_unit:GetOrigin(), 500, false )
		local side = ""
		local tower = ""
		if string.find(value, "dire") then 
			side = "dire"
		else
			side = "radi"
		end

		if string.find(value, "tower_a") then
			tower = "towerA"
		else
			tower = "towerB"
		end
		tower_unit:SetUnitName(value) -- set the unit name to be used in the unvuln tower modifier
		GridNav:DestroyTreesAroundPoint( tower_trigger:GetOrigin(), 500, false )
		tower_unit:SetOrigin(tower_trigger:GetOrigin())
		--tower_unit:SetModel("models/items/world/towers/ti10_dire_tower/ti10_dire_tower.vmdl")
		--tower_unit:EnableMotion()
		Score.round4[side][tower] = tower_unit
		print("Tower Type = " .. type(tower_unit))
		PrintTable(tower_unit)
	end

	local boss_spawner = Entities:FindByName(nil, ROUND4_SPAWNER_BOSS)
	Score.round4.boss_handle = CreateUnitByName( ROUND4_BOSS_UNIT, boss_spawner:GetOrigin(),        true, nil, nil, DOTA_TEAM_CUSTOM_1 )
	Score.round4.boss_handle:AddNewModifier(nil, nil, "modifier_invuln_tower_based", {})

end

