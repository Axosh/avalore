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
    Score.flags.a = {}
    Score.flags.a.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flags.a.inBase = false
    Score.flags.b = {}
    Score.flags.b.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flags.b.inBase = false
    Score.flags.c = {}
    Score.flags.c.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flags.c.inBase = false
    Score.flags.d = {}
    Score.flags.d.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flags.d.inBase = false
    Score.flags.e = {}
    Score.flags.e.currTeamPossession = DOTA_TEAM_NOTEAM
    Score.flags.e.inBase = false

    -- Towers
    Score.towers = {}
    Score.towers.radi = {}
    Score.towers.dire = {}
    Score.towers.radi.top1 = true
    Score.towers.radi.top2 = true
    Score.towers.radi.top3 = true
    Score.towers.radi.mid1 = true
    Score.towers.radi.mid2 = true
    Score.towers.radi.mid3 = true
    Score.towers.radi.bot1 = true
    Score.towers.radi.bot2 = true
    Score.towers.radi.bot3 = true
    Score.towers.radi.t4top = true
    Score.towers.radi.t4bot = true

    Score.towers.dire.top1 = true
    Score.towers.dire.top2 = true
    Score.towers.dire.top3 = true
    Score.towers.dire.mid1 = true
    Score.towers.dire.mid2 = true
    Score.towers.dire.mid3 = true
    Score.towers.dire.bot1 = true
    Score.towers.dire.bot2 = true
    Score.towers.dire.bot3 = true
    Score.towers.dire.t4top = true
    Score.towers.dire.t4bot = true

    -- Raxes
    Score.raxes = {}
    Score.raxes.radi = {}
    Score.raxes.dire = {}
    Score.raxes.radi.topranged = true
    Score.raxes.radi.topmelee = true
    Score.raxes.radi.midranged = true
    Score.raxes.radi.midmelee = true
    Score.raxes.radi.botranged = true
    Score.raxes.radi.botmelee = true

    Score.raxes.dire.topranged = true
    Score.raxes.dire.topmelee = true
    Score.raxes.dire.midranged = true
    Score.raxes.dire.midmelee = true
    Score.raxes.dire.botranged = true
    Score.raxes.dire.botmelee = true

    -- build player score tracking 
    Score.playerStats = {}
    -- for playerID = 0, DOTA_MAX_PLAYERS do
    --     print("Id = " .. playerID)
    --     if PlayerResource:IsValidPlayerID(playerID) then
    --         print("Valid Player = " .. playerID)
    --         if not PlayerResource:IsBroadcaster(playerID) then
    --             print("Player Id Inserted into Table = " .. playerID)
    --             Score.playerStats[playerID].t1 = 0
    --             Score.playerStats[playerID].t2 = 0
    --             Score.playerStats[playerID].t3 = 0
    --             Score.playerStats[playerID].t4 = 0

    --             Score.playerStats[playerID].rangeRax = 0
    --             Score.playerStats[playerID].meleeRax = 0

    --             Score.playerStats[playerID].wisps = 0

    --             Score.playerStats[playerID].flag_captures = 0
    --         end
    --     end
    -- end
end

function Score:InsertPlayerStatsRecord(playerID)
    Score.playerStats[playerID] = {}
    Score.playerStats[playerID].t1 = 0
    Score.playerStats[playerID].t2 = 0
    Score.playerStats[playerID].t3 = 0
    Score.playerStats[playerID].t4 = 0

    Score.playerStats[playerID].rangeRax = 0
    Score.playerStats[playerID].meleeRax = 0

    Score.playerStats[playerID].wisps = 0

    Score.playerStats[playerID].flag_captures = 0
end

function Score:RecalculateScores()
    Score.RadiScore = 0
    Score.DireScore = 0

    -- total up player scores
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then

                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                local tmpScore = 0
                tmpScore = tmpScore + math.floor(hero:GetKills() / SCORE_DIVIDEND_KILLS)
                tmpScore = tmpScore + math.floor(hero:GetAssists() / SCORE_DIVIDEND_ASSISTS)
                tmpScore = tmpScore + math.floor(hero:GetLastHits() / SCORE_DIVIDEND_LASTHITS)
                if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
                    Score.RadiScore = Score.RadiScore + tmpScore
                elseif hero:GetTeam() == DOTA_TEAM_BADGUYS then
                    Score.DireScore = Score.DireScore + tmpScore
                end
            end
        end
    end

    -- check radiant tower status (and give points to dire accordingly)
    for key,value in pairs(Score.towers.radi) do
        if value == false then
            if string.find(key, "1") then
                Score.DireScore = Score.DireScore + SCORE_MULTIPLIER_T1
            elseif string.find(key, "2") then
                Score.DireScore = Score.DireScore + SCORE_MULTIPLIER_T2
            elseif string.find(key, "3") then
                Score.DireScore = Score.DireScore + SCORE_MULTIPLIER_T3
            elseif string.find(key, "4") then
                Score.DireScore = Score.DireScore + SCORE_MULTIPLIER_T4
            end
        end
    end

    --check dire tower status (and give points to radiant accordingly)
    for key,value in pairs(Score.towers.dire) do
        if value == false then
            if string.find(key, "1") then
                Score.RadiScore = Score.RadiScore + SCORE_MULTIPLIER_T1
            elseif string.find(key, "2") then
                Score.RadiScore = Score.RadiScore + SCORE_MULTIPLIER_T2
            elseif string.find(key, "3") then
                Score.RadiScore = Score.RadiScore + SCORE_MULTIPLIER_T3
            elseif string.find(key, "4") then
                Score.RadiScore = Score.RadiScore + SCORE_MULTIPLIER_T4
            end
        end
    end

    -- PLACEHOLDER: rax checks

    -- PLACEHOLDER: rosh checks

    -- PLACEHOLDER: outposts/king of the hill

    -- PLACEHOLDER: CTF
    for key, value in pairs(Score.flags) do
        if(value.currTeamPossession == DOTA_TEAM_GOODGUYS) then
            Score.RadiScore = Score.RadiScore + SCORE_MULTIPLIER_FLAG
        elseif value.currTeamPossession == DOTA_TEAM_BADGUYS then
            Score.DireScore = Score.DireScore + SCORE_MULTIPLIER_FLAG
        end
    end

    -- wisps
    Score.RadiScore = Score.RadiScore + (Score.round1.radi_wisp_count * SCORE_MULTIPLIER_WISP)
    
    Score.DireScore = Score.DireScore + (Score.round1.dire_wisp_count * SCORE_MULTIPLIER_WISP)

    -- repaint scores
    print( "radi score = " .. tostring(Score.RadiScore))
    print( "dire score = " .. tostring(Score.DireScore))

    DeepPrintTable(Score.playerStats)

    local score_obj = 
    {
        radi_score = Score.RadiScore,
        dire_score = Score.DireScore
    }
    CustomGameEventManager:Send_ServerToAllClients( "refresh_score", score_obj )

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
