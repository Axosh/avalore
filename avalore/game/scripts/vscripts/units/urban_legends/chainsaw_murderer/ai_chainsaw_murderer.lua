require("references")
require(REQ_AI_SHARED)

LinkLuaModifier( "modifier_urban_legend",  "units/urban_legends/modifier_urban_legend.lua",        LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_avalore_not_auto_attackable", "scripts/vscripts/modifiers/modifier_avalore_not_auto_attackable.lua", LUA_MODIFIER_MOTION_NONE )

UL_ACT_PATROL = 0
UL_ACT_AGGRO = 1
UL_ACT_DEAGGRO = 2
UL_ACT_CARRY = 3

AVALORE_UL_AGGRO_DUR = 9.0
AVALORE_UL_DEAGGRO_DUR = 5.0

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
    thisEntity.nAggroRange = thisEntity:GetAcquisitionRange()

    hHook = thisEntity:FindAbilityByName("pudge_meat_hook")
    hHook:SetLevel(4)
    hGrab = thisEntity:FindAbilityByName("ability_ul_grab")
    hGrab:SetLevel(1)


    thisEntity.patrol_route = {}
    thisEntity.patrol_step = 1
    thisEntity.debug_side = "Radi"

    thisEntity:SetContextThink("ChainsawMurdererAIThink", ChainsawMurdererAIThink, 1)
end

function ChainsawMurdererAIThink( self )
    -- =================================================================
    -- INIT
    -- =================================================================
    if thisEntity.FirstPass then
		thisEntity.spawnLocation = thisEntity:GetOrigin() -- location still (0,0,0) when in Spawn function, so set it on first pass here
        thisEntity:AddNewModifier(thisEntity, nil, "modifier_urban_legend", { })
        thisEntity:AddNewModifier(thisEntity, nil, "modifier_avalore_not_auto_attackable", {})
		thisEntity.FirstPass = false
        thisEntity.lastOutpostAttempt = GameRules:GetGameTime()
        local midpoint
        local flag
        local gem
        -- determine patrol route
        if IsOnRadiantSide(thisEntity:GetOrigin().x, thisEntity:GetOrigin().y) then
            thisEntity.outpost = Score.entities.radi_outpost
            thisEntity.tree = Entities:FindByName(nil, "trigger_radi_tree")
            midpoint = Entities:FindByName(nil, "spawner_round4_radi")
            flag = Entities:FindByName(nil, "spawner_flag_c")
            gem = Entities:FindByName(nil, "trigger_radi_gem_activate")
        else
            thisEntity.outpost = Score.entities.dire_outpost
            thisEntity.tree = Entities:FindByName(nil, "trigger_dire_tree")
            midpoint = Entities:FindByName(nil, "spawner_round4_dire")
            flag = Entities:FindByName(nil, "spawner_flag_d")
            gem = Entities:FindByName(nil, "trigger_dire_gem_activate")
            thisEntity.debug_side = "Dire"
        end

        thisEntity.patrol_route = {thisEntity.spawnLocation, midpoint:GetOrigin(), flag:GetOrigin(), gem:GetOrigin(), thisEntity.outpost:GetOrigin(), gem:GetOrigin(), flag:GetOrigin(), midpoint:GetOrigin()}
        PrintTable(thisEntity.patrol_route)
        thisEntity.currPatrolTarget = thisEntity.patrol_route[thisEntity.patrol_step]
	end

    -- =================================================================
    -- WAIT
    -- =================================================================

    -- with resdesign, they should never die
    -- if not self:IsAlive() then
    --     thisEntity.currentAction = UL_ACT_PATROL
    --     return
    -- end
	if GameRules:IsGamePaused() then
		return 0.1
	end

    -- =================================================================
    -- ACTIONS
    -- =================================================================
    -- double check this just in case
    if thisEntity:FindModifierByName("modifier_ul_grab_self") then
        thisEntity.currentAction = UL_ACT_CARRY
    end

    if thisEntity.currentAction == UL_ACT_CARRY then
        -- make sure we're still carrying
        if thisEntity:FindModifierByName("modifier_ul_grab_self") then
            -- -- did we make it to the tree?
            -- if thisEntity:IsTouching(thisEntity.tree) then
                
            -- end
            if (thisEntity:GetAbsOrigin() - thisEntity.tree:GetAbsOrigin()):Length2D() < 200 then
                (thisEntity:FindModifierByName("modifier_ul_grab_self")):Complete()
                thisEntity.currentAction = UL_ACT_PATROL
                thisEntity.patrol_step = 1
            end

            print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Walking to Tree")
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
                print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Aggro'd on " .. hRandomPlayer:GetUnitName())
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
            print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Deaggro")
        -- otherwise, try to grab our target
        else
            -- close enough to grab?
            local hVisibleEnemies = GetVisibleEnemyHeroesInRangeForNeutrals( thisEntity, hGrab:GetCastRange(thisEntity:GetAbsOrigin(), nil) )
            if #hVisibleEnemies > 0 then
                print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Try Grab")
                local hRandomEnemy = hVisibleEnemies[ RandomInt( 1, #hVisibleEnemies ) ]
                --PrintTable(hRandomEnemy)
                if hGrab:IsCooldownReady() and hGrab:IsFullyCastable() and (not hRandomEnemy:FindModifierByName("modifier_ul_grab_debuff")) then
                    print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Casting Grab on " .. hRandomEnemy:GetUnitName())
                    CastGrab(hRandomEnemy)
                    -- see if grab succeeded
                    if thisEntity:FindModifierByName("modifier_ul_grab_self") then
                        thisEntity.currentAction = UL_ACT_CARRY
                        print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Carrying to Sacrifice Tree")
                    end
                    return 1
                end
            else
                -- can we hook?
                local hVisibleEnemies = GetVisibleEnemyHeroesInRangeForNeutrals( thisEntity, hHook:GetCastRange(thisEntity:GetAbsOrigin(), nil) )
                if #hVisibleEnemies > 0 then
                    print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Try Hook")
                    local rand = RandomInt( 1, #hVisibleEnemies )
                    --PrintTable(hVisibleEnemies)
                    -- print("Rand Num = " .. tostring(rand))
                    local hRandomEnemy = hVisibleEnemies[ rand ]
                    print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Casting Hook on " .. hRandomEnemy:GetUnitName())
                    -- print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Target At: ")
                    --PrintVector(hRandomEnemy:GetAbsOrigin())
                    local dirFacing = hRandomEnemy:GetForwardVector()
                    local ms = hRandomEnemy:GetMoveSpeedModifier(hRandomEnemy:GetBaseMoveSpeed(), false)
                    local guesstimateFuturePos = dirFacing * (ms * 2)
                    -- print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Throwing Hook At: ")
                    -- PrintVector(guesstimateFuturePos)
                    if hHook:IsCooldownReady() and hHook:IsFullyCastable() then
                        CastHook(hRandomEnemy, guesstimateFuturePos)
                        hHook:RefundManaCost()
                        return 1
                    end
                end
            end

            -- if we made it this far without casting anything, then try to auto-attack
            -- print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Auto-Attacking: ")
            -- ExecuteOrderFromTable({
			-- 	UnitIndex = thisEntity:entindex(),
			-- 	OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			-- 	TargetIndex = thisEntity.hCurrTarget:entindex(),
			-- })
            ExecuteOrderFromTable({
                UnitIndex = thisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                TargetIndex = thisEntity.hCurrTarget:entindex(),
                })
            return RandomFloat( 0.5, 1.5 )
        end
    end

    if thisEntity.currentAction == UL_ACT_DEAGGRO then
        local curr_deaggro_dur = GameRules:GetGameTime() - thisEntity.fTimeWeLostAggro
        if curr_deaggro_dur > AVALORE_UL_DEAGGRO_DUR then
            thisEntity.fTimeWeLostAggro = nil
            thisEntity.currentAction = UL_ACT_PATROL
            print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Lost Aggro")
        end
    end

    if (   thisEntity.currentAction == UL_ACT_DEAGGRO
        or thisEntity.currentAction == UL_ACT_PATROL  ) then
            -- try to steal the outpost if near it
            if ((GameRules:GetGameTime() - thisEntity.lastOutpostAttempt > 20) and
                (thisEntity:GetAbsOrigin() - thisEntity.outpost:GetAbsOrigin()):Length2D() < 400 ) then

                print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] Trying to Steal Outpost")
                -- ExecuteOrderFromTable({
                --     UnitIndex = thisEntity:entindex(),
                --     OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                --     TargetIndex = thisEntity.outpost:entindex(),
                --     --Position = thisEntity.outpost:GetAbsOrigin(),
                -- })
                ExecuteOrderFromTable({
                    UnitIndex = thisEntity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                    TargetIndex = thisEntity.outpost:entindex(),
                    --Position = thisEntity.outpost:GetAbsOrigin(),
                })
            end
            -- see if we're at target location (within 200 radius)
            if (thisEntity:GetAbsOrigin() - thisEntity.currPatrolTarget):Length2D() < 200 then
                -- if we've gotten to the end of the route, reset it
                if thisEntity.patrol_step == (#(thisEntity.patrol_route)) then
                    thisEntity.patrol_step = 1
                else
                    thisEntity.patrol_step = thisEntity.patrol_step + 1
                end

                -- get next target to patrol to
                thisEntity.currPatrolTarget = thisEntity.patrol_route[thisEntity.patrol_step]
                print("[AI - Chainsaw Murderer - " .. thisEntity.debug_side .. "] New Patrol Target " .. tostring(thisEntity.patrol_step))
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
    --print("Firing Hook")
    --PrintVector(position)
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = hTarget:GetOrigin() + position,
		AbilityIndex = hHook:entindex(),
		--TargetIndex = hTarget:GetEntityIndex(),
		Queue = false,
	})
end