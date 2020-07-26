--[[
Avalore Game Mode
]]

_G.nCOUNTDOWNTIMER = 2401
_G.Temp = false
_G.round = 0
_G.first_loop = true
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
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(CAvaloreGameMode, "OnItemPickUp"), self)
	-- ListenToGameEvent("dota_inventory_item_changed", Dynamic_Wrap(CAvaloreGameMode, "OnItemSlotChanged"), self)
	-- ListenToGameEvent("inventory_updated", Dynamic_Wrap(CAvaloreGameMode, "OnInventoryUpdated"), self)
	-- ListenToGameEvent("dota_item_gifted", Dynamic_Wrap(CAvaloreGameMode, "OnItemGifted"), self)
	-- ListenToGameEvent("dota_inventory_changed", Dynamic_Wrap(CAvaloreGameMode, "OnInventoryChanged"), self)
	-- ListenToGameEvent( "dota_item_spawned", Dynamic_Wrap( CAvaloreGameMode, "OnItemSpawned" ), self )
	_G.nCOUNTDOWNTIMER = 2401
	self.countdownEnabled = true
	GameRules:SetPreGameTime( 10 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	
	-- Custom Mode Framework Inits
	Spawners:Init()
	Score:Init()
	-- set unselectable so they can't be captured until round2 begins
	-- also note: force set the team to NOTEAM later on or the engine forces 
	--            them to begin as radiant and dire owned
	Score.entities.radi_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})
	Score.entities.dire_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})

	--[[local score_obj = 
	{
		radi_score = 0,
		dire_score = 0
	}
	CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )
	--]]
end

-- Evaluate the state of the game
function CAvaloreGameMode:OnThink()

	--grab current time as a float, excluding pregame and negative time
	curr_gametime = GameRules:GetDOTATime(false, false)

	if self.countdownEnabled == true then
		CountdownTimer()
		--_G.nCOUNTDOWNTIMER = _G.nCOUNTDOWNTIMER - 1;
		--print("Countdown = " .. tostring(_G.nCOUNTDOWNTIMER))
	end

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

	--TEMP ==> force debug: set hero to lvl 6
	local p1_hero = PlayerResource:GetSelectedHeroEntity(0)
	-- if p1_hero then
	-- 	print("Mana Regen = " .. tostring(p1_hero:GetManaRegen()))
	-- end
	--if p1_hero ~= nil and p1_hero:GetLevel() < 6 then
	if p1_hero ~= nil and p1_hero:GetLevel() < 20 then
		p1_hero:HeroLevelUp(false)
		--p1_hero:UpgradeAbility(bSupressSpeech)
		p1_hero:HeroLevelUp(false)
		p1_hero:HeroLevelUp(false)
		p1_hero:HeroLevelUp(false)
		p1_hero:HeroLevelUp(false)
	end

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

function CAvaloreGameMode:InitRound1()
	-- spawn 7 wisps
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
		CreateUnitByName( ROUND1_WISP_UNIT, vSpawnLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
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
		local tower_unit = CreateUnitByName( ROUND4_TOWER_UNIT, tower_trigger:GetOrigin(),        true, nil, nil, DOTA_TEAM_NEUTRALS )
		GridNav:DestroyTreesAroundPoint( tower_unit:GetOrigin(), 500, false )
	end

	local boss_spawner = Entities:FindByName(nil, ROUND4_SPAWNER_BOSS)
	CreateUnitByName( ROUND4_BOSS_UNIT, boss_spawner:GetOrigin(),        true, nil, nil, DOTA_TEAM_NEUTRALS )

end