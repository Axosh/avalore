--[[
Avalore Game Mode
]]

_G.nCOUNTDOWNTIMER = 2401
_G.Temp = false
_G.round = 0
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

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	LinkLuaModifier( "modifier_unselectable", "scripts/vscripts/round2/building_outpost.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_capturable", "scripts/vscripts/round2/building_outpost.lua", LUA_MODIFIER_MOTION_NONE )
end

-- Create the game mode when we activate
function Activate()
	CAvaloreGameMode:InitGameMode()
end

---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function CAvaloreGameMode:InitGameMode()
	print( "Avalore is loaded." )
	--GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 1 )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CAvaloreGameMode, "OnEntityKilled"), self)
	_G.nCOUNTDOWNTIMER = 2401
	self.countdownEnabled = true
	GameRules:SetPreGameTime( 10 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	print( "CAvaloreGameMode:InitGameMode()" )
	Spawners:Init()


	local score_obj = 
	{
		radi_score = 0,
		dire_score = 0
	}
	CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )


	--local outpostTest = CreateUnitByName( 'radiant_outpost', Vector(-3904, 3008, 384), true, nil, nil, DOTA_TEAM_NOTEAM )--Entities:FindByName(nil, "radiant_outpost")
	--outpostTest:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})
	--temp_outpost = CreateUnitByName( 'radiant_outpost', Vector(-3904, 3008, 394), true, nil, nil, DOTA_TEAM_NOTEAM )
	--temp_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})

	radi_outpost = Entities:FindByName(nil, "radiant_outpost")
	radi_outpost:SetTeam(DOTA_TEAM_NEUTRALS)
	radi_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})
	dire_outpost = Entities:FindByName(nil, "dire_outpost")
	dire_outpost:SetTeam(DOTA_TEAM_NEUTRALS)
	dire_outpost:AddNewModifier(outpostTest, nil, "modifier_unselectable", {})
end

-- Evaluate the state of the game
function CAvaloreGameMode:OnThink()

	--grab current time as a float, excluding pregame and negative time
	curr_gametime = GameRules:GetDOTATime(false, false)--GameRules:GetGameTime()
	if self.countdownEnabled == true then
		CountdownTimer()
		--_G.nCOUNTDOWNTIMER = _G.nCOUNTDOWNTIMER - 1;
		--print("Countdown = " .. tostring(_G.nCOUNTDOWNTIMER))
	end
	--print("Gametime = " .. tostring(curr_gametime))
	--print("_G.Temp = " .. tostring(_G.Temp))

	if curr_gametime > 20 and _G.Temp == false then
		_G.Temp = true
	end
	-- game more: wisps
	--0-600 = wisp
	--600-1200 = koth
	--1200-1800 = boss
	--1800-2400 = waves
	if curr_gametime > 1800 then
		print("waves")
	elseif curr_gametime > 1200 then
		print("boss")
	elseif curr_gametime > 600 then 
		print("koth")
	--[[elseif curr_gametime > 20 then
		--testing route switching
		--if(_G.round < 2) then
			print("trying to switch path route")
			_G.round = 2
			local start_node = Entities:FindByName(nil, "radiant_path_start")
			local next_node = Entities:FindByName(nil, "dire_path_mid_recombine")
			--start_node:InputSetNextPathCorner(next_node)
		end
		--]]
	elseif curr_gametime > 0 then
		--print("capture")
		if(_G.round < 1) then
			--TEMP ==> force debug: set hero to lvl 6
			local p1_hero = PlayerResource:GetSelectedHeroEntity(0)
			p1_hero:HeroLevelUp(false)
			p1_hero:HeroLevelUp(false)
			p1_hero:HeroLevelUp(false)
			p1_hero:HeroLevelUp(false)
			p1_hero:HeroLevelUp(false)
			_G.round = 1
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
				CreateUnitByName( 'npc_avalore_quest_wisp', vSpawnLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
			end
			local broadcast_obj = 
			{
				msg = "#Round1",
				time = 10,
				elaboration = "#Round1Info"
			}
			CustomGameEventManager:Send_ServerToAllClients( "broadcast_message", broadcast_obj )
		end

		-- temp test
		if(math.floor(curr_gametime) == 5) then
			print("clearing modifier")
			dire_outpost:RemoveModifierByName("modifier_unselectable")
			radi_outpost:RemoveModifierByName("modifier_unselectable")
			--local outpostTest = Entities:FindByName(nil, "radiant_outpost")
			--outpostTest:RemoveModifierByName("modifier_unselectable")
			--temp_outpost:RemoveModifierByName("modifier_unselectable")
			--temp_outpost:RemoveModifierByName("modifier_invulnerable")
			--temp_outpost:AddNewModifier(outpostTest, nil, "modifier_capturable", {})
			--local TempTest = Entities:FindByName(nil, "radiant_outpost")
			--TempTest:RemoveModifierByName("modifier_invulnerable")
			--TempTest:AddNewModifier(outpostTest, nil, "modifier_capturable", {})

			--[[print("temp_outpost")
			for key, value in pairs(temp_outpost:FindAllModifiers()) do
				print(value:GetName())
			end
			print("TempTest")
			for key, value in pairs(TempTest:FindAllModifiers()) do
				print(value:GetName())
			end
			--]]
			
		end
	elseif curr_gametime == 0 then
		dire_outpost:SetTeam(DOTA_TEAM_NOTEAM)
		radi_outpost:SetTeam(DOTA_TEAM_NOTEAM)
	end

	if radi_outpost:GetTeam() == DOTA_TEAM_GOODGUYS then
		t_radi_outpost.radiTime = t_radi_outpost.radiTime + 1
	elseif radi_outpost:GetTeam() == DOTA_TEAM_BADGUYS then
		t_radi_outpost.direTime = t_radi_outpost.direTime + 1
	end

	if dire_outpost:GetTeam() == DOTA_TEAM_GOODGUYS then
		t_dire_outpost.radiTime = t_dire_outpost.radiTime + 1
	elseif dire_outpost:GetTeam() == DOTA_TEAM_BADGUYS then 
		t_dire_outpost.direTime = t_dire_outpost.direTime + 1
	end

	print("R-Outpost RTime = " .. tostring(t_radi_outpost.radiTime))
	print("R-Outpost DTime = " .. tostring(t_radi_outpost.direTime))
	print("D-Outpost RTime = " .. tostring(t_dire_outpost.radiTime))
	print("D-Outpost DTime = " .. tostring(t_dire_outpost.direTime))
	print("******************************")

	--TEMP
	--print("GameTime = " .. tostring(curr_gametime) .. ", Eval = " .. tostring(math.floor(curr_gametime) % 30))
	if(curr_gametime > 0 and math.floor(curr_gametime) % 30 == 0) then
		Spawners:SpawnLaneCreeps(math.floor(curr_gametime))
	end
	--END TEMP

	--print("CAvaloreGameMode:OnThink() - Ended")
	return 1
end