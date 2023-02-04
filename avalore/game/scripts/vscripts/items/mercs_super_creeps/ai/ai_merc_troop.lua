require("references")
require(REQ_AI_SHARED)

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    if IsRadiantTopLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
        thisEntity.waypoints = {"radiant_path_top_1", "radiant_path_top_2", "radiant_path_end"}
    elseif IsRadiantBotLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
        thisEntity.waypoints = {"radiant_path_bot_1", "radiant_path_bot_2", "radiant_path_end"}
    elseif IsDireTopLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
        thisEntity.waypoints = {"dire_path_top_1", "dire_path_top_2", "dire_path_end"}
    elseif IsDireBotLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
        thisEntity.waypoints = {"dire_path_bot_1", "dire_path_bot_2", "dire_path_end"}
    else
        print("Failed to determine Merc Troop Pathing Waypoints")
    end

    thisEntity.currWaypoint = 0
    thisEntity.behavior = DOTA_UNIT_ORDER_ATTACK_MOVE

    thisEntity:SetContextThink("TroopAIThink", YetiAIThink, 1)
end

function TroopAIThink(self)
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    local waypoint = Entities:FindByName(self.waypoints[self.currWaypoint])
    -- only update next waypoint if we're not on the last one
    if self.currWaypoint < 2 then
        local dist = self:GetAbsOrigin() - waypoint:GetAbsOrigin()
        -- check to see if we're within 100 units of their waypoint
        if dist:Length2D() < 100 then
            self.currWaypoint = self.currWaypoint + 1
        end
    end

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = thisEntity.behavior,
        Position = waypoint:GetOrigin(),
        AbilityIndex = nil,
        Queue = false,
    })
    return 1
end