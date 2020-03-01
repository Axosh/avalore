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
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CAvaloreGameMode, "OnEntityKilled"), self)
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
		Score:UpdateRound2()
		Score:DebugRound2()
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
	elseif curr_gametime == 0 and _G.first_loop then
		self.GameStartInit()
		_G.first_loop = false
	end

	--TEMP ==> force debug: set hero to lvl 6
	local p1_hero = PlayerResource:GetSelectedHeroEntity(0)
	if p1_hero ~= nil and p1_hero:GetLevel() < 6 then
		p1_hero:HeroLevelUp(false)
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
		CreateUnitByName( 'npc_avalore_quest_wisp', vSpawnLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
	end

	-- broadcast that round 1 has started and give some instructions
	local broadcast_obj = 
	{
		msg = "#Round1",
		time = 10,
		elaboration = "#Round1Info"
	}
	CustomGameEventManager:Send_ServerToAllClients( "broadcast_message", broadcast_obj )
end

function CAvaloreGameMode:InitRound2()
	print("clearing modifier")
	Score.entities.dire_outpost:RemoveModifierByName("modifier_unselectable")
	Score.entities.radi_outpost:RemoveModifierByName("modifier_unselectable")
end

function CAvaloreGameMode:InitRound3()
	return 0 -- placeholder
end

function CAvaloreGameMode:InitRound3()
	return 0 --placeholder
end