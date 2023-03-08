require("references")
require(REQ_AI_SHARED)

AI_WAYPOINTS = {}
AI_WAYPOINTS["raditop"] = {"radiant_path_top_1", "radiant_path_top_2", "radiant_path_end"}
AI_WAYPOINTS["radibot"] = {"radiant_path_bot_1", "radiant_path_bot_2", "radiant_path_end"}
--AI_WAYPOINTS["radibot"] = {"radi_merc_path_1", "radiant_path_bot_2", "radiant_path_end"}
AI_WAYPOINTS["diretop"] = {"dire_path_top_1", "dire_path_top_2", "dire_path_end"}
--AI_WAYPOINTS["diretop"] = {"dire_merc_path_1", "dire_path_top_2", "dire_path_end"}
AI_WAYPOINTS["direbot"] = {"dire_path_bot_1", "dire_path_bot_2", "dire_path_end"}
--AI_WAYPOINTS["direbot"] = {"dire_merc_path_1", "dire_path_bot_2", "dire_path_end"}

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    thisEntity.currWaypoint = 1 -- lua is 1-indexed, not 0-indexed

    thisEntity.behavior = DOTA_UNIT_ORDER_ATTACK_MOVE
    -- find a better way to do this, but for now it should be good enough
    print(thisEntity:GetUnitName())
    if thisEntity:GetUnitName() == "npc_avalore_merc_ent" then
        thisEntity.behavior = DOTA_UNIT_ORDER_ATTACK_TARGET
    end

    thisEntity.TargetThreat = THREAT_NONE --don't have a target to start with
    thisEntity.ForcedReturnToLaneCountdown = 0 -- timer for forcing a return to lane

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
            return 0.1
        end
    end

    --PrintTable(thisEntity)

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
    --print(waypoint)
    -- only update next waypoint if we're not on the last one
    if thisEntity.currWaypoint < 3 then
        local dist = thisEntity:GetAbsOrigin() - waypoint:GetAbsOrigin()
        -- check to see if we're within 100 units of their waypoint
        if dist:Length2D() < 100 then
            thisEntity.currWaypoint = thisEntity.currWaypoint + 1
        end
    end

    -- ExecuteOrderFromTable({
    --     UnitIndex = thisEntity:entindex(),
    --     OrderType = thisEntity.behavior,
    --     Position = waypoint:GetOrigin(),
    --     AbilityIndex = nil,
    --     Queue = false,
    -- })

    if thisEntity:GetUnitName() == "npc_avalore_merc_ent" then
        SiegeTroopBehavior(thisEntity, waypoint)
        -- ExecuteOrderFromTable({
        --         UnitIndex = thisEntity:entindex(),
        --         OrderType = thisEntity.behavior,
        --         Position = waypoint:GetOrigin(),
        --         AbilityIndex = nil,
        --         Queue = false,
        --     })
    else
        DefaultTroopBehavior(thisEntity, waypoint)
    end
    return 1
end

FIND_NEW_TARGET = 1
FIND_NEW_TARGET_IF_BETTER = 2
DONT_FIND_NEW_TARGET = 3

THREAT_HERO = 1
THREAT_TOWER = 2
THREAT_BUILDING = 3
THREAT_SELF = 4
THREAT_LOW = 5
THREAT_NONE = 6

function SiegeTroopBehavior(thisEntity, waypoint)
    -- see if there's something to attack if we're not already attacking
    
    if not thisEntity:IsAttacking() then
        --local enemies = GetVisibleEnemiesNearby(thisEntity, thisEntity:GetAcquisitionRange())
        local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetAbsOrigin(), nil, thisEntity:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
        --local enemies = GetBuildingsNearby(thisEntity, thisEntity:GetAcquisitionRange())
        if #enemies > 0 then
            print("[SiegeTroopBehavior] Found Targets")
            local priorityThreatLevel = THREAT_NONE
            local priorityTarget = nil
            for index,enemy in pairs(enemies) do
                local targetName = enemy:GetUnitName()
                if not targetName then
                    targetName = enemy:GetName()
                end
                print("[SiegeTroopBehavior] Looking at Target => " .. targetName)
                -- only care about buildings
                if ( (string.find(targetName, "tower") ~= nil or -- towers
				    string.find(targetName, "_rax_") ~= nil or --melee/ranged rax
					string.find(targetName, "_fort") ~= nil or --ancient
					targetName == "building_arcanery" or
					targetName == "mercenary_camp")
				) then
                    print("[SiegeTroopBehavior] Looking at Threat Target => " .. targetName)
                    local testThreat = THREAT_BUILDING
                    if string.find(targetName, "tower") ~= nil then
                        testThreat = THREAT_TOWER
                    end

                    print("Threat Found = " .. tostring(testThreat))
                    print("Current Threat = " .. tostring(thisEntity.TargetThreat))

                    -- see if this is a better target than our current
                    if testThreat < thisEntity.TargetThreat then
                        -- see if this is better than the best one we found so far
                        if testThreat < priorityThreatLevel then
                            priorityThreatLevel = testThreat
                            priorityTarget = enemy
                        end
                    end
                end
            end

            if priorityTarget then
                print("[SiegeTroopBehavior] Target => " .. priorityTarget:GetName())
                thisEntity.TargetThreat = priorityThreatLevel
                thisEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
                ExecuteOrderFromTable({
                    UnitIndex = thisEntity:entindex(),
                    TargetIndex = priorityTarget:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    AbilityIndex = nil,
                    Queue = false,
                })
                return
            end
        -- if no targets, then keep walking towards the next waypoint
        --else
        end
        -- if we got here (no real target)
            print("[SiegeTroopBehavior] Moving to Next Waypoint")
            thisEntity:SetAttackCapability( DOTA_UNIT_CAP_NO_ATTACK )
            thisEntity.TargetThreat = THREAT_NONE
            thisEntity:MoveToPosition(waypoint:GetOrigin())
            -- ExecuteOrderFromTable({
            --     UnitIndex = thisEntity:entindex(),
            --     OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            --     Position = waypoint:GetOrigin(),
            --     AbilityIndex = nil,
            --     Queue = false,
            -- })
    else
        print("[SiegeTroopBehavior] IN COMBAT")
        -- if we're attacking, make sure it's a real target
        local targetName = thisEntity:GetAttackTarget():GetUnitName()
        if not targetName then
            targetName = thisEntity:GetAttackTarget():GetName()
        end
        if ( (string.find(targetName, "tower") ~= nil or -- towers
				    string.find(targetName, "_rax_") ~= nil or --melee/ranged rax
					string.find(targetName, "_fort") ~= nil or --ancient
					targetName == "building_arcanery" or
					targetName == "mercenary_camp")
				) then
            return
        else
            print("[SiegeTroopBehavior] IN COMBAT => Re-Routing Because Not Building")
            thisEntity:SetAttackCapability( DOTA_UNIT_CAP_NO_ATTACK )
            thisEntity.TargetThreat = THREAT_NONE
            thisEntity:MoveToPosition(waypoint:GetOrigin())
        end
    end
end

function DefaultTroopBehavior(thisEntity, waypoint)
    local findNewTarget = FIND_NEW_TARGET
    -- if we're already in combat
    if thisEntity:IsAttacking() then
        local target = thisEntity:GetAttackTarget()
        local threat = EvaluateThreat(thisEntity, target)
        thisEntity.TargetThreat = threat
        if threat == THREAT_LOW then
            findNewTarget = FIND_NEW_TARGET_IF_BETTER
        elseif threat == THREAT_SELF then
            -- if we're already fighting a hero, don't worry about switching
            if target:IsHero() then
                findNewTarget = DONT_FIND_NEW_TARGET
            else
                findNewTarget = FIND_NEW_TARGET_IF_BETTER
            end
        else
            findNewTarget = DONT_FIND_NEW_TARGET
        end
    else
        thisEntity.TargetThreat = THREAT_NONE
    end

    -- evaluate nearby targets
    if findNewTarget ~= DONT_FIND_NEW_TARGET then
        local enemies = GetVisibleEnemiesNearby(thisEntity, thisEntity:GetAcquisitionRange())
        if #enemies > 0 then
            local priorityThreatLevel = THREAT_NONE
            local priorityTarget = nil
            for index,enemy in pairs(enemies) do
                local testThreat = EvaluateThreat(thisEntity, enemy)
                -- if we found something attacking a higher priority target, take that
                if testThreat < thisEntity.TargetThreat then
                    priorityThreatLevel = testThreat
                    priorityTarget = enemy
                end
            end

            if priorityTarget then
                thisEntity.TargetThreat = priorityThreatLevel
                -- track to see if we wandered too far away from the lane
                thisEntity.LocationBeforeLastAttackMove = thisEntity:GetAbsOrigin()
                ExecuteOrderFromTable({
                    UnitIndex = thisEntity:entindex(),
                    TargetIndex = priorityTarget:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    --OrderType = thisEntity.behavior,
                    --Position = waypoint:GetOrigin(),
                    AbilityIndex = nil,
                    Queue = false,
                })
                return
            end
        end
    end

    -- see if we've wandered too far
    if thisEntity.ForcedReturnToLaneCountdown == 0 and thisEntity:GetAttackTarget() then
        --if thisEntity.LocationBeforeLastAttackMove then
            if DistanceBetweenVectors(thisEntity.LocationBeforeLastAttackMove, thisEntity:GetAbsOrigin()) > 2000 then
                thisEntity.ForcedReturnToLaneCountdown = 3
            end
        --end
    end

    -- force walk
    if thisEntity.ForcedReturnToLaneCountdown > 0 then
        thisEntity.ForcedReturnToLaneCountdown = thisEntity.ForcedReturnToLaneCountdown - 1
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = waypoint:GetOrigin(),
            AbilityIndex = nil,
            Queue = false,
        })
        return
    elseif not thisEntity:GetAttackTarget() then
        thisEntity.LocationBeforeLastAttackMove = thisEntity:GetAbsOrigin()
        ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = thisEntity.behavior,
                Position = waypoint:GetOrigin(),
                AbilityIndex = nil,
                Queue = false,
            })
            return
    end
end

function EvaluateThreat(thisEntity, unit)
    local target = unit:GetAttackTarget()
    if not target then
        return THREAT_NONE
    end
    local targetName = target:GetUnitName()
    if not targetName then
        targetName = target:GetName()
    end
    
    if target:IsHero() then
        return THREAT_HERO
    -- buildings
    elseif (string.find(targetName, "tower") ~= nil) then
        return THREAT_TOWER
    elseif (string.find(targetName, "_rax_") ~= nil or --melee/ranged rax
            string.find(targetName, "_fort") ~= nil or --ancient
            targetName == "building_arcanery" or
            targetName == "mercenary_camp"
            ) then
        return THREAT_BUILDING
    elseif target == thisEntity then
        return THREAT_SELF
    else
        return THREAT_LOW
    end
end