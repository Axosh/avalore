if Score == nil then
    Score = {}
end

function Score:Init()
    Score.RadiScore = 0
    Score.DireScore = 0

    Score.round1 = {}
    Score.round1.radi_wisp_count = 0
    Score.round1.dire_wisp_count = 0

    Score.round2 = {}
    Score.round2.radi_outpost = {}
    Score.round2.radi_outpost.radi_time = 0
    Score.round2.radi_outpost.dire_time = 0

    Score.round2.dire_outpost = {}
    Score.round2.dire_outpost.radi_time = 0
    Score.round2.dire_outpost.dire_time = 0
    -- cached refs to entities
    Score.entities = {}
    Score.entities.radi_outpost = Entities:FindByName(nil, "radiant_outpost")
    Score.entities.dire_outpost = Entities:FindByName(nil, "dire_outpost")

    -- Flags
    Score.flags = {}
    Score.flag.a = {}
    Score.flag.a.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flag.a.inBase = false
    Score.flag.b = {}
    Score.flag.b.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flag.b.inBase = false
    Score.flag.c = {}
    Score.flag.c.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flag.c.inBase = false
    Score.flag.d = {}
    Score.flag.d.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flag.d.inBase = false
    Score.flag.e = {}
    Score.flag.e.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flag.e.inBase = false
end

function Score:RecalculateScores()
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                local tmpScore = 0
                tmpScore = tmpScore + math.floor(hero:GetKills() / SCORE_DIVIDEND_KILLS)
                tmpScore = tmpScore + math.floor(hero:GetAssists() / SCORE_DIVIDEND_ASSISTS)
                tmpScore = tmpScore + math.floor(hero:GetLastHits() / SCORE_DIVIDEND_LASTHITS)
            end
        end
    end
end

--[[
    Gets run every second of round 2 so we can total up the amount of time each team
    held each outpost and award points.
--]]
function Score:UpdateRound2()
    -- check owner of the outpost in the radiant jungle and update accordingly
    if Score.entities.radi_outpost:GetTeam() == DOTA_TEAM_GOODGUYS then
		Score.round2.radi_outpost.radi_time = Score.round2.radi_outpost.radi_time + 1
	elseif Score.entities.radi_outpost:GetTeam() == DOTA_TEAM_BADGUYS then
		Score.round2.radi_outpost.dire_time = Score.round2.radi_outpost.dire_time + 1
	end

    -- check owner of the outpost in the dire jungle and update accordingly
	if Score.entities.dire_outpost:GetTeam() == DOTA_TEAM_GOODGUYS then
		Score.round2.dire_outpost.radi_time = Score.round2.dire_outpost.radi_time + 1
	elseif Score.entities.dire_outpost:GetTeam() == DOTA_TEAM_BADGUYS then 
		Score.round2.dire_outpost.dire_time = Score.round2.dire_outpost.dire_time + 1
	end
end

function Score:DebugRound2()
    print("=====================================")
	print("R-Outpost RTime = " .. tostring(Score.round2.radi_outpost.radi_time))
    print("R-Outpost DTime = " .. tostring(Score.round2.radi_outpost.dire_time))
    print("*****")
	print("D-Outpost RTime = " .. tostring(Score.round2.dire_outpost.radi_time))
	print("D-Outpost DTime = " .. tostring(Score.round2.dire_outpost.dire_time))
    print("=====================================")
end
