require("references")
require(REQ_AI_SHARED)

UL_ACT_PATROL = 0
UL_ACT_AGGRO = 1
UL_ACT_CARRY = 2

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
        
    end
end