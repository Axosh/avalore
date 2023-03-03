require("references")
require(REQ_AI_SHARED)

AI_WAYPOINTS = {}
AI_WAYPOINTS["raditop"] = {"radiant_path_top_1", "radiant_path_top_2", "radiant_path_end"}
AI_WAYPOINTS["radibot"] = {"radiant_path_bot_1", "radiant_path_bot_2", "radiant_path_end"}
AI_WAYPOINTS["diretop"] = {"dire_path_top_1", "dire_path_top_2", "dire_path_end"}
AI_WAYPOINTS["direbot"] = {"dire_path_bot_1", "dire_path_bot_2", "dire_path_end"}

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    thisEntity.currWaypoint = 1 -- lua is 1-indexed, not 0-indexed
    thisEntity.behavior = DOTA_UNIT_ORDER_ATTACK_MOVE

    thisEntity:SetContextThink("TroopAIThink", TroopAIThink, 1)
end

function TroopAIThink()
    if not thisEntity:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    if thisEntity.waypoints == nil then
        PrintVector(thisEntity:GetAbsOrigin(), "AI Spawn Loc")
        if IsRadiantTopLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
            thisEntity.waypoints = "raditop"
            --thisEntity.waypoints = {"radiant_path_top_1", "radiant_path_top_2", "radiant_path_end"}
        elseif IsRadiantBotLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
            thisEntity.waypoints = "radibot"
            --thisEntity.waypoints = {"radiant_path_bot_1", "radiant_path_bot_2", "radiant_path_end"}
        elseif IsDireTopLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
            thisEntity.waypoints = "diretop"
            --thisEntity.waypoints = {"dire_path_top_1", "dire_path_top_2", "dire_path_end"}
        elseif IsDireBotLane(thisEntity:GetAbsOrigin().x, thisEntity:GetAbsOrigin().y) then
            thisEntity.waypoints = "direbot"
            --thisEntity.waypoints = {"dire_path_bot_1", "dire_path_bot_2", "dire_path_end"}
        else
            print("Failed to determine Merc Troop Pathing Waypoints")
        end
    end

    PrintTable(thisEntity)

    -- adding in some attack deteciton because apparently they don't see towers as targets
    -- oof, nm - this was because towers are invuln before first wave spawns
    -- local hVisibleEnemies = GetVisibleEnemiesNearby( thisEntity, nAggroRange )
    -- if #hVisibleEnemies > 0 then
    --     local hRandomEnemy = hVisibleEnemies[ RandomInt( 1, #hVisibleEnemies ) ]
    --     ExecuteOrderFromTable({
    --         UnitIndex = thisEntity:entindex(),
    --         OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
    --         Position = hRandomEnemy:GetOrigin(),
    --         AbilityIndex = nil,
    --         Queue = false,
    --     })
    -- end

    --local waypoint = Entities:FindByName(self.waypoints[self.currWaypoint])
    --print("Waypoint? " .. thisEntity.waypoints)
    local waypointSet = AI_WAYPOINTS[thisEntity.waypoints]
    if not waypointSet then
        print("Couldn't Find Waypoints")
    end
    local nextWaypointName = waypointSet[thisEntity.currWaypoint]
    if not nextWaypointName then
        print("Couldn't find next waypoint name")
    end
    local waypoint = Entities:FindByName(nil, nextWaypointName)
    print(waypoint)
    -- only update next waypoint if we're not on the last one
    if thisEntity.currWaypoint < 2 then
        local dist = thisEntity:GetAbsOrigin() - waypoint:GetAbsOrigin()
        -- check to see if we're within 100 units of their waypoint
        if dist:Length2D() < 100 then
            thisEntity.currWaypoint = thisEntity.currWaypoint + 1
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