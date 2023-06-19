require("references")
require(REQ_AI_SHARED)

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    -- figure out if we're on dire or radiant side
    local dire_spawn = Entities:FindByName(nil, "spawner_round4_dire")
    local dist = thisEntity:GetAbsOrigin() - dire_spawn:GetAbsOrigin()

    thisEntity.waypoint = "dire_path_end"
    -- if we're more than 500 units, can assume this is a radiant side spawn
    if dist:Length2D() > 500 then
        thisEntity.waypoint = "radiant_path_end"
    end
    thisEntity.behavior = DOTA_UNIT_ORDER_ATTACK_MOVE

    thisEntity:SetContextThink("Round4CreepAIThink", YetiAIThink, 1)
end

function Round4CreepAIThink(self)
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    local waypoint = Entities:FindByName(nil, thisEntity.waypoint)

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = thisEntity.behavior,
        Position = waypoint:GetOrigin(),
        AbilityIndex = nil,
        Queue = false,
    })
    return 1
end