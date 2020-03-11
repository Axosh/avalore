---------------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------------
require("score")
require("utility_functions")

--initialized with ListenToGameEvent("entity_killed", Dynamic_Wrap(CustomGameMode, "OnEntityKilled"), self)
function CAvaloreGameMode:OnEntityKilled(event)
	--print("OnEntityKilled - Started")
	local killedEntity 		= EntIndexToHScript(event.entindex_killed)
	local killedTeam 		= killedEntity:GetTeam()
	local attackerEntity 	= EntIndexToHScript( event.entindex_attacker )
	local attackerTeam 		= nil --attackerEntity:GetTeam()

	local refreshScores = false

	if attackerEntity ~= nil then
		attackerTeam = attackerEntity:GetTeam()
	end

	--Check for bonus points due to quest objective
	local objectivePoints = 0
	if killedEntity:GetUnitName() == "npc_avalore_quest_wisp" then
		--objectivePoints = 3
		refreshScores = true
		if attackerTeam == DOTA_TEAM_GOODGUYS then
			Score.round1.radi_wisp_count = Score.round1.radi_wisp_count + 1
		elseif attackerTeam == DOTA_TEAM_BADGUYS then
			Score.round1.dire_wisp_count = Score.round1.dire_wisp_count + 1
		end
		Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps = Score.playerStats[attackerEntity:GetPlayerOwnerID()].wisps + 1
		--attackerEntity:IncrementKills(999)
		--attackerEntity:IncrementKills(999)
		--attackerEntity:IncrementKills(999)
	end
	--Hero Kills, excluding denies
	if killedEntity:IsRealHero() and attackerTeam ~= killedTeam then
		--objectivePoints = 1
		refreshScores = true
	end

	-- only update front-end if score changed
	if refreshScores then
		Score:RecalculateScores()
	-- if objectivePoints > 0 then 
	-- 	if attackerTeam == DOTA_TEAM_GOODGUYS then
	-- 		Score.RadiScore = Score.RadiScore + objectivePoints
	-- 		local score = 
	-- 		{
	-- 			team_id = DOTA_TEAM_GOODGUYS,
	-- 			team_score = Score.RadiScore
	-- 		}
	-- 	elseif attackerTeam == DOTA_TEAM_BADGUYS then
	-- 		Score.DireScore = Score.DireScore + objectivePoints
	-- 		local score = 
	-- 		{
	-- 			team_id = DOTA_TEAM_BADGUYS,
	-- 			team_score = Score.DireScore
	-- 		}
	-- 	end

		--print( "radi score = " .. _G.GoodScore)
		--print( "radi score 2 = " .. GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
		--print( "dire score = " .. _G.BadScore)

		-- local score_obj = 
		-- {
		-- 	radi_score = Score.RadiScore,
		-- 	dire_score = Score.DireScore
		-- }
		-- CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )

		--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_BADGUYS, GetTeamHeroKills(DOTA_TEAM_BADGUYS))
		--GameRules:GetGameModeEntity():SetTopBarTeamValue(DOTA_TEAM_GOODGUYS, GetTeamHeroKills(DOTA_TEAM_GOODGUYS))
	end

	--print("OnEntityKilled - Ended")
end

function CAvaloreGameMode:OnHeroFinishSpawn(event)
	PrintTable(event)
	local hPlayerHero = EntIndexToHScript( event.heroindex )
	if hPlayerHero ~= nil and hPlayerHero:IsRealHero() then
		if hPlayerHero.bFirstSpawnComplete == nil then
			hPlayerHero.bFirstSpawnComplete = true
			Score:InsertPlayerStatsRecord(hPlayerHero:GetPlayerOwnerID())
		end
	end
end