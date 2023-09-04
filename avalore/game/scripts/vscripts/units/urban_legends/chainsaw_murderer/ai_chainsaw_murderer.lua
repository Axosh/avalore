require("references")
require(REQ_AI_SHARED)

UL_ACT_PATROL = 0
UL_ACT_AGGRO = 1
UL_ACT_DEAGGRO = 2
UL_ACT_CARRY = 3

AVALORE_UL_AGGRO_DUR = 9.0
AVALORE_UL_DEAGGRO_DUR = 5.0

UL_PATROL_TARG_HOOK = 1
UL_PATROL_TARG_OUTPOST = 2

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then
        return
    end

    thisEntity.isCarrying = false
    thisEntity.FirstPass = true
    thisEntity.fTimeAggroStarted = nil
    thisEntity.fTimeWeLostAggro = nil
    thisEntity.currentAction = 0
    thisEntity.hCurrTarget = nil
    thisEntity.iCurrPatTarget = nil
    thisEntity.nAggroRange = thisEntity:GetAcquisitionRange()

    thisEntity:SetContextThink("ChainsawMurdererAIThink", ChainsawMurdererAIThink, 1)
    hHook = thisEntity:FindAbilityByName("pudge_meat_hook")
    hGrab = thisEntity:FindAbilityByName("ability_ul_grab")
end

function ChainsawMurdererAIThink( self )
    -- =================================================================
    -- INIT
    -- =================================================================
    if thisEntity.FirstPass then
		thisEntity.spawnLocation = thisEntity:GetOrigin() -- location still (0,0,0) when in Spawn function, so set it on first pass here
		thisEntity.FirstPass = false
        -- determine patrol route
        if IsOnRadiantSide(thisEntity:GetOrigin().x, thisEntity:GetOrigin().y) then
            thisEntity.outpost = Score.entities.radi_outpost
        else
            thisEntity.outpost = Score.entities.dire_outpost
        end

        thisEntity.currPatrolTarget = thisEntity.outpost
        thisEntity.iCurrPatTarget = UL_PATROL_TARG_OUTPOST
	end

    -- =================================================================
    -- WAIT
    -- =================================================================

    if not self:IsAlive() then
        thisEntity.currentAction = UL_ACT_PATROL
    	return
    end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    -- =================================================================
    -- ACTIONS
    -- =================================================================

    if thisEntity.currentAction == UL_ACT_CARRY then
        -- make sure we're still carrying
        if thisEntity:FindModifierByName("modifier_ul_grab_self") then
            ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = thisEntity.spawnLocation,
			})
            return 0.5
        else
            thisEntity.currentAction = UL_ACT_PATROL
        end
    end

    -- Look for Targets while walking between points
    if thisEntity.currentAction == UL_ACT_PATROL then
        -- check for targets
        local hVisiblePlayers = GetVisibleEnemyHeroesInRangeForNeutrals( thisEntity, nAggroRange )
        if #hVisiblePlayers > 0 then
            -- select target and make sure valid still
            local hRandomPlayer = hVisiblePlayers[ RandomInt( 1, #hVisiblePlayers ) ]
            if hRandomPlayer ~= nil then
                thisEntity.currentAction = UL_ACT_AGGRO
                thisEntity.fTimeAggroStarted = GameRules:GetGameTime()
                thisEntity.hCurrTarget = hRandomPlayer
            end
        end
    end

    if thisEntity.currentAction == UL_ACT_AGGRO then
        local curr_aggro_dur = GameRules:GetGameTime() - thisEntity.fTimeAggroStarted

        -- if we've been aggro'd too long, lose it and go back to patrol
        if curr_aggro_dur > AVALORE_UL_AGGRO_DUR then
            thisEntity.fTimeWeLostAggro = GameRules:GetGameTime()
            thisEntity.fTimeAggroStarted = nil
            thisEntity.currentAction = UL_ACT_DEAGGRO
        -- otherwise, try to grab our target
        else
            -- close enough to grab?
            local hVisibleEnemies = GetVisibleEnemiesNearby( thisEntity, hGrab:GetCastRange() )
            if #hVisibleEnemies > 1 then
                local hRandomEnemy = hVisibleEnemies[ RandomInt( 1, #hVisibleEnemies ) ]
                CastGrab(hRandomEnemy)
                -- see if grab succeeded
                if thisEntity:FindModifierByName("modifier_ul_grab_self") then
                    thisEntity.currentAction = UL_ACT_CARRY
                end
                return 1
            end

            -- can we hook?
            local dirFacing = thisEntity.hCurrTarget:GetForwardVector()
            local ms = thisEntity.hCurrTarget:GetMoveSpeedModifier(hRandomPlayer:GetBaseMoveSpeed(), false)
            local guesstimateFuturePos = dirFacing * (ms * 2)
            if hHook:IsCooldownReady() and hHook:IsFullyCastable() then
                CastHook(thisEntity.hCurrTarget, guesstimateFuturePos)
                hHook:RefundManaCost()
                return 1
            end
        end

        
    end

    if thisEntity.currentAction == UL_ACT_DEAGGRO then
        local curr_deaggro_dur = GameRules:GetGameTime() - thisEntity.fTimeWeLostAggro
        if curr_aggro_dur > AVALORE_UL_DEAGGRO_DUR then
            thisEntity.fTimeWeLostAggro = nil
            thisEntity.currentAction = UL_ACT_PATROL
        end
    end

    if (   thisEntity.currentAction == UL_ACT_DEAGGRO
        or thisEntity.currentAction == UL_ACT_PATROL  ) then
            -- see if we're at target location (within 200 radius)
            if (thisEntity:GetAbsOrigin() - thisEntity.currPatrolTarget:GetAbsOrigin()):Length2D() < 200 then
                if thisEntity.iCurrPatTarget == UL_PATROL_TARG_OUTPOST then
                    thisEntity.iCurrPatTarget = UL_PATROL_TARG_HOOK
                    thisEntity.currPatrolTarget = thisEntity.spawnLocation
                else
                    thisEntity.iCurrPatTarget = UL_PATROL_TARG_OUTPOST
                    thisEntity.currPatrolTarget = thisEntity.outpost
                end
            end

            -- move to target location
            ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = thisEntity.currPatrolTarget,
			})
            return 0.5
    end
    return 0.5
end

function CastGrab ( hTarget )
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		--Position = hTarget:GetOrigin(),
		AbilityIndex = hGrab:entindex(),
		TargetIndex = hTarget:GetEntityIndex(),
		Queue = false,
	})
end

function CastHook ( hTarget, position )
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		Position = position,
		AbilityIndex = hHook:entindex(),
		TargetIndex = hTarget:GetEntityIndex(),
		Queue = false,
	})
end