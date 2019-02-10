-- Generated from template

_G.nCOUNTDOWNTIMER = 2401

if CAvaloreGameMode == nil then
	_G.CAvaloreGameMode = class({})
	--CAvaloreGameMode = class({})
end

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
	nCOUNTDOWNTIMER = 2401
end

-- Evaluate the state of the game
function CAvaloreGameMode:OnThink()
	--if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	--	--print( "Avalore script is running." )
	--elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	--	return nil
	--end
	if self.countdownEnabled == true then
		CountdownTimer()
	end
	return 1
end