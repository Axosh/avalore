--[[
Avalore Game Mode
]]

_G.nCOUNTDOWNTIMER = 2401
_G.Temp = false
_G.round = 0

---------------------------------------------------------------------------
-- CAvaloreGameMode class
---------------------------------------------------------------------------

if CAvaloreGameMode == nil then
	_G.CAvaloreGameMode = class({})
end

---------------------------------------------------------------------------
-- Required .lua files
---------------------------------------------------------------------------
--require( "events" )
--require( "items" )
require( "utility_functions" )

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
	--GameRules.Avalore = CAvaloreGameMode()
	--GameRules.Avalore:InitGameMode()
end

---------------------------------------------------------------------------
-- Initializer
---------------------------------------------------------------------------
function CAvaloreGameMode:InitGameMode()
	print( "Avalore is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	_G.nCOUNTDOWNTIMER = 2401
	print( "CAvaloreGameMode:InitGameMode()" )
	self.countdownEnabled = true
	GameRules:SetPreGameTime( 10 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
end

-- Evaluate the state of the game
function CAvaloreGameMode:OnThink()
	--if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	--	--print( "Avalore script is running." )
	--elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	--	return nil
	--end
	curr_gametime = GameRules:GetGameTime()
	if self.countdownEnabled == true then
		CountdownTimer()
		--_G.nCOUNTDOWNTIMER = _G.nCOUNTDOWNTIMER - 1;
		print("Countdown = " .. tostring(_G.nCOUNTDOWNTIMER))
	end
	print("Gametime = " .. tostring(curr_gametime))
	print("_G.Temp = " .. tostring(_G.Temp))

	if curr_gametime > 20 and _G.Temp == false then
		local broadcast_obj =
		{
			msg = "#Helloworld",
			time = 5
		}
		local test = 
		{
			msg = "test"
		}
		CustomGameEventManager:Send_ServerToAllClients( "broadcast_message", broadcast_obj )
		--CustomGameEventManager:Send_ServerToAllClients( "test", test )
		EmitGlobalSound( "DOTA_Item.Refresher.Activate" )
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
	elseif curr_gametime > 0 then
		print("capture")
		if(_G.round < 1) then
			_G.round = 1
			for i = 0,6,1
			do
				local vSpawnLoc = Vector(0,0,0) + RandomVector(2000)
				--npc_dota_wisp_spirit
				CreateUnitByName( 'npc_avalore_quest_wisp', vSpawnLoc, true, nil, nil, DOTA_TEAM_NEUTRALS )
			end
		end
	end
	return 1
end