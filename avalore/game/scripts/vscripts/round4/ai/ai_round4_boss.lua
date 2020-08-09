require("references")
require(REQ_AI_SHARED)

function Spawn( entityKeyValues )
    if IsServer() then
		if thisEntity == nil then
			return
        end

        thisEntity.FirstPass = true
        thisEntity.walkingHome = false
        
        --hDefBlast    = thisEntity:FindAbilityByName("invoker_deafening_blast")
        hDragonSlave = thisEntity:FindAbilityByName("lina_dragon_slave")
        hMysticSnake = thisEntity:FindAbilityByName("medusa_mystic_snake")
        hMysticFlare = thisEntity:FindAbilityByName("skywrath_mage_mystic_flare")
        thisEntity:SetContextThink("Round4BossAIThink", Round4BossAIThink, 1)
    end
end

function Round4BossAIThink( self )
    if thisEntity.FirstPass then
        thisEntity.spawnLocation = thisEntity:GetOrigin() -- location still (0,0,0) when in Spawn function, so set it on first pass here
		thisEntity.FirstPass = false
    end
    
    if not self:IsAlive() then
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
    end
    
    local nAggroRange = thisEntity:GetAcquisitionRange()
    -- see if we need to go back home 
	local xDist = thisEntity.spawnLocation.x - thisEntity:GetOrigin().x
	local yDist = thisEntity.spawnLocation.y - thisEntity:GetOrigin().y
	local distanceFromSpawn = math.sqrt( (xDist ^ 2) + (yDist ^ 2) )

	if distanceFromSpawn > (nAggroRange * 5) then
		thisEntity.walkingHome = true
    end
    
    if thisEntity.walkingHome == false then
        local hVisiblePlayers = GetVisibleEnemyHeroesInRange( thisEntity, nAggroRange )
		if #hVisiblePlayers <= 0 then
			return 0.5
		end

		local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]
		if hRandomPlayer == nil then
			return 0.5
        end
        --print("Mystic Snake Castable? ==> " .. tostring(hMysticSnake:IsFullyCastable()))

        -- CAST SPELLS
        if hMysticFlare:IsFullyCastable() then
            print("Cast Mystic Flair")
            CastMysticFlare(hRandomPlayer)
            return 1
        elseif hDragonSlave:IsFullyCastable() then
            print("Cast Dragon Slave")
            CastDragonSlave(hRandomPlayer)
            return 1
        -- elseif hDefBlast:IsFullyCastable() then
        --     CastDefBlast(hRandomPlayer)
        --     return 1
        elseif hMysticSnake:IsFullyCastable() then
            print("Cast Mystic Flare")
            CastMysticSnake(hRandomPlayer)
            return 1
        end
    else
		if distanceFromSpawn > 50 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = thisEntity.spawnLocation,
			})
		else
			thisEntity.walkingHome = false
		end
	end

	return RandomFloat( 0.5, 1.5 )
end

-- ABILITY CASTS
-- function CastDefBlast( hTarget )
-- 	ExecuteOrderFromTable({
-- 		UnitIndex = thisEntity:entindex(),
-- 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
-- 		Position = hTarget:GetOrigin(),
-- 		AbilityIndex = hDefBlast:entindex(),
-- 		Queue = false,
-- 	})
-- end

function CastDragonSlave( hTarget )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hTarget:GetOrigin(),
		AbilityIndex = hDragonSlave:entindex(),
		Queue = false,
	})
end

function CastMysticSnake( hTarget )
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		Position = hTarget:GetOrigin(),
		AbilityIndex = hMysticSnake:entindex(),
		Queue = false,
	})
end

function CastMysticFlare( hTarget )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hTarget:GetOrigin(),
		AbilityIndex = hMysticFlare:entindex(),
		Queue = false,
	})
end