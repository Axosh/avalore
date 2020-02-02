---------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------


--initialized with ListenToGameEvent("entity_killed", Dynamic_Wrap(CustomGameMode, "OnEntityKilled"), self)
function CAvaloreGameMode:OnEntityKilled(event)
	print("OnEntityKilled - Started")
	local killedEntity 		= EntIndexToHScript(event.entindex_killed)
	local killedTeam 		= killedEntity:GetTeam()
	local attackerEntity 	= EntIndexToHScript( event.entindex_attacker )
	local attackerTeam 		= nil --attackerEntity:GetTeam()

	if attackerEntity ~= nil then
		attackerTeam = attackerEntity:GetTeam()
	end

	--Check for bonus points due to quest objective
	local objectivePoints = 0
	if killedEntity:GetUnitName() == "npc_avalore_quest_wisp" then
		objectivePoints = 3
	end
	--Hero Kills, excluding denies
	if killedEntity:IsRealHero() and attackerTeam ~= killedTeam then
		objectivePoints = 1
	end

	if attackerTeam == DOTA_TEAM_GOODGUYS then
		_G.GoodScore = _G.GoodScore + objectivePoints
	elseif attackerTeam == DOTA_TEAM_BADGUYS then
		_G.BadScore = _G.BadScore + objectivePoints
	end
	print( "radi score = " .. _G.GoodScore)
	print( "dire score = " .. _G.BadScore)

	GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, _G.GoodScore)
	GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, _G.BadScore)
	print("OnEntityKilled - Ended")
end