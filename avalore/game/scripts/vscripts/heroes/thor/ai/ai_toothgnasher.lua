require("references")
require(REQ_AI_SHARED)

function Spawn(entityKeyValues)
    if (not IsServer()) or (thisEntity == nil) then return end

    thisEntity:SetContextThink("ToothgnasherAIThink", ToothgnasherAIThink, 1)
end

function ToothgnasherAIThink(self)
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    --local thor = Entities:FindByClassname(nil, "npc_avalore_hero_thor")
    local thor = Entities:FindByClassname(nil, "npc_dota_hero_dawnbreaker")
    if thor and thor:IsAlive() then
        -- see if we need to go back towards thor 
        local xDist = thor:GetAbsOrigin().x - thisEntity:GetAbsOrigin().x
        local yDist = thor:GetAbsOrigin().y - thisEntity:GetAbsOrigin().y
        local distanceFromThor = math.sqrt( (xDist ^ 2) + (yDist ^ 2) )

        if distanceFromThor > 2000 then
            print("Warp - Too far from Thor!")
            -- TODO: logic to warp goat to thor
            self.waypoint = nil --clear current waypoint
        elseif distanceFromThor > 500 then
            print("Follow - Too far from Thor!")
            self.waypoint = nil --clear current waypoint
            --MoveToUnitPosition(thor)
            -- add some jitter so they don't clump
            self:MoveToPosition(thor:GetAbsOrigin() + RandomVector( RandomFloat( 20, 20)))
        else
            if self.waypoint then
                print("Have Waypoint")
                local xWpDist = self.waypoint.x - thisEntity:GetAbsOrigin().x
                local yWpDist = self.waypoint.y - thisEntity:GetAbsOrigin().y
                local distanceFromWp = math.sqrt( (xWpDist ^ 2) + (yWpDist ^ 2) )
                print("Distance from Waypoint = " .. tostring(distanceFromWp))
                -- we're close enough
                if distanceFromWp < 10 then
                    self.waypoint = nil --clear current waypoint
                else
                    self:MoveToPosition(self.waypoint)
                end
            else
                print("Set Waypoint")
                local waypoint = thisEntity:GetAbsOrigin() + RandomVector( RandomFloat( 100, 300 ) )
                if GridNav:CanFindPath( self:GetAbsOrigin(), waypoint ) then
                    self.waypoint = waypoint
                    PrintVector(waypoint, "Set a new waypoint")
                end
            end
        end
    else
        print("Thor not found")
    end

    return 1
end

-- function MoveToUnitPosition( hTarget )

-- 	thisEntity.vEmergeGoalPos = hTarget:GetAbsOrigin()

-- 	thisEntity:SetInitialGoalEntity( nil )

-- 	local MoveOrder =
-- 	{
-- 		UnitIndex = thisEntity:entindex(),
-- 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
-- 		Position = thisEntity.vEmergeGoalPos,
-- 		Queue = true,
-- 	}

-- 	ExecuteOrderFromTable( MoveOrder )

-- 	thisEntity.hEmergeTarget = hTarget

-- 	local fTimeToWait = 0.1

-- 	return fTimeToWait
-- end