--[[
Avalore Game Mode
]]

_G.nCOUNTDOWNTIMER = 2401
_G.Temp = false
_G.round = 0
_G.GoodScore = 0
_G.BadScore = 0

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
	elseif curr_gametime > 20 then
		--testing route switching
		if(_G.round < 2) then
			print("trying to switch path route")
			_G.round = 2
			local start_node = Entities:FindByName(nil, "radiant_path_start")
			local next_node = Entities:FindByName(nil, "dire_path_mid_recombine")
			--start_node:InputSetNextPathCorner(next_node)
		end
	elseif curr_gametime > 0 then
		--print("capture")
		if(_G.round < 1) then
			_G.round = 1
			for i = 0,6,1
			do
				local vSpawnLoc = nil
				while vSpawnLoc == nil do
					vSpawnLoc = Vector(0,0,0) + RandomVector(2000)
					if (GridNav:CanFindPath(Vector(0,0,0), vSpawnLoc) == false) then
						print( "Choosing new unit spawnloc.  Bad spawnloc was: " .. tostring( vSpawnLoc ) )
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
	end

	--TEMP
	print(math.floor(curr_gametime))
	if(curr_gametime > 0 and math.floor(curr_gametime) % 30 == 0) then
		Spawners:SpawnLaneCreeps(math.floor(curr_gametime))
	end
	--END TEMP

	--print("CAvaloreGameMode:OnThink() - Ended")
	return 1
end