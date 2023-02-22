require("references")
require(REQ_AI_SHARED)

function Spawn( entityKeyValues )
    if IsServer() then
		if thisEntity == nil then
			return
        end

        thisEntity.FirstPass = true
		thisEntity.walkingHome = false
		thisEntity.LastTarget = nil
		thisEntity.MaxDistFromSpawn = (thisEntity:GetAcquisitionRange() * 10)
		thisEntity.MaxIdleDistFromSpawn = 50
        
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
    
    local nAggroRange = thisEntity:GetAcquisitionRange() * 2
    -- see if we need to go back home 
	local xDist = thisEntity.spawnLocation.x - thisEntity:GetOrigin().x
	local yDist = thisEntity.spawnLocation.y - thisEntity:GetOrigin().y
	local distanceFromSpawn = math.sqrt( (xDist ^ 2) + (yDist ^ 2) )

	-- if there are no visible targets and we're not at spawn, go back to spawn
	local hVisiblePlayers = GetVisibleEnemyHeroesInRangeForNeutrals( thisEntity, nAggroRange )
	if #hVisiblePlayers <= 0 then
		--print("Round 4 Boss ==> No Players Around || Aggro Range = " .. tostring(nAggroRange))
		-- See if we were hunting a target that's not too far off our spawn location
		if thisEntity.LastTarget ~= nil then
			if not thisEntity.LastTarget:IsAlive() then 
				thisEntity.LastTarget = nil
				thisEntity.walkingHome = true
			else
				local xDistTarg = thisEntity.LastTarget:GetOrigin().x - thisEntity.spawnLocation.x
				local yDistTarg = thisEntity.LastTarget:GetOrigin().y - thisEntity.spawnLocation.y
				local distanceFromTarg = math.sqrt( (xDistTarg ^ 2) + (yDistTarg ^ 2) )
				if distanceFromTarg > thisEntity.MaxDistFromSpawn then
					thisEntity.LastTarget = nil
					thisEntity.walkingHome = true
				end
			end
		elseif distanceFromSpawn > thisEntity.MaxIdleDistFromSpawn then
			--print("Round 4 Boss ==> Going Home")
			thisEntity.walkingHome = true
		else
			return 0.5 -- chill out and idle in the pit
		end
	else
		--print("Round 4 Boss ==> Trying to Aggro")
		thisEntity.walkingHome = false
	end

	-- if we are too far from home spawn, forcibly go back to spawn 
	if distanceFromSpawn > thisEntity.MaxDistFromSpawn then
		--print("Round 4 Boss ==> Too far, forced home")
		thisEntity.walkingHome = true
	end
    
	if thisEntity.walkingHome == false then
		--print("Round 4 Boss ==> Normal AI Logic")
		local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]
		if hRandomPlayer == nil then
			if thisEntity.LastTarget ~= nil then
				hRandomPlayer = thisEntity.LastTarget
			else
				return 0.5
			end
		else
			thisEntity.LastTarget = hRandomPlayer
		end
		
		--print("Round 4 Boss ==> Targetting ==> " .. hRandomPlayer:GetUnitName())

        --print("Mystic Snake Castable? ==> " .. tostring(hMysticSnake:IsFullyCastable()))

        -- CAST SPELLS
        if hMysticFlare:IsCooldownReady() and hMysticFlare:IsFullyCastable() then
            --print("Cast Mystic Flare")
            CastMysticFlare(hRandomPlayer)
            return 1
        elseif hDragonSlave:IsCooldownReady() and hDragonSlave:IsFullyCastable() then
            --print("Cast Dragon Slave")
            CastDragonSlave(hRandomPlayer)
            return 1
        -- elseif hDefBlast:IsFullyCastable() then
        --     CastDefBlast(hRandomPlayer)
        --     return 1
        elseif hMysticSnake:IsCooldownReady() and hMysticSnake:IsFullyCastable() then
            --print("Cast Mystic Snake")
            CastMysticSnake(hRandomPlayer)
			return 1
		else
			--print("Issue Attack")
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = hRandomPlayer:GetOrigin(),
			})
        end
	else
		--print("Round 4 Boss ==> Walking Home")
		if distanceFromSpawn > thisEntity.MaxIdleDistFromSpawn then
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
		--Position = hTarget:GetOrigin(),
		AbilityIndex = hMysticSnake:entindex(),
		TargetIndex = hTarget:GetEntityIndex(),
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