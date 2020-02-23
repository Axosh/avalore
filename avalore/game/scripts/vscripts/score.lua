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
