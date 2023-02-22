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

        -- abilities
        hSlam = thisEntity:FindAbilityByName("roshan_slam")

        thisEntity:SetContextThink("RoshAIThink", RoshAIThink, 1)
    end
end

function RoshAIThink(self)
	if thisEntity.FirstPass then
		--print("Origin = " .. tostring(thisEntity:GetOrigin()) .. " || Abs Origin = " .. tostring(thisEntity:GetAbsOrigin()))
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
			-- go home if wandered too far
			thisEntity.walkingHome = true
		else
			return 0.5 -- chill out and idle in the pit
		end
	else
		-- trying to aggro
		thisEntity.walkingHome = false
	end

	-- if we are too far from home spawn, forcibly go back to spawn 
	if distanceFromSpawn > thisEntity.MaxDistFromSpawn then
		thisEntity.walkingHome = true
	end
    
	if thisEntity.walkingHome == false then
		-- normal logic
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

        -- CAST SPELLS (if applicable)
        local hSlamTargets = GetVisibleEnemyHeroesInRangeForNeutrals( thisEntity, 350 ) --350 is the radius of slam
        if #hSlamTargets > 2 then
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                AbilityIndex = hSlam:entindex(),
                Queue = false,
            })
        else
			--print("Issue Attack")
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = hRandomPlayer:GetOrigin(),
			})
        end
        
	else
		-- go home
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