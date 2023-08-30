require("references")
require(REQ_AI_SHARED)

function Spawn( entityKeyValues )
    if not IsServer() then return end
    if thisEntity == nil then
        return
    end

    thisEntity.isCarrying = false
    thisEntity.FirstPass = true

    thisEntity:SetContextThink("ChainsawMurdererAIThink", ChainsawMurdererAIThink, 1)
    hHook = thisEntity:FindAbilityByName("pudge_meat_hook")
    hGrab = thisEntity:FindAbilityByName("ability_ul_grab")
end

function ChainsawMurdererAIThink( self )
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
end