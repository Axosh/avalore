require("references")
require(REQ_CONSTANTS)
require(REQ_SCORE)
require(REQ_UTIL)



function GemTrigger_OnStartTouch(trigger)
    print("Touching GemTrigger")
    local triggerName = thisEntity:GetName()
    if trigger.activator ~= nil and trigger.caller ~= nil then
        local activator_entindex = trigger.activator:GetEntityIndex()
		local caller_entindex = trigger.caller:GetEntityIndex()
        local NPC = EntIndexToHScript( activator_entindex )
        local TriggerEntity = EntIndexToHScript( caller_entindex )
        local triggerSide = nil
        if string.find(TriggerEntity:GetName(), "radi") then
            triggerSide = DOTA_TEAM_GOODGUYS
        elseif string.find(TriggerEntity:GetName(), "dire") then
            triggerSide = DOTA_TEAM_BADGUYS
        end

        -- don't do anything unless this is a Player Owned Hero and on one of their team's capture points
        -- (i.e. capture point on the opposite side of the map)
        if NPC ~= nil and NPC:IsHero() and NPC:IsOwnedByAnyPlayer() and NPC:GetTeam() ~= triggerSide then
            if NPC:HasItemInInventory(OBJECTIVE_GEM_ITEM) then
                -- Consume Gem
                local hItem = NPC:FindItemInInventory(OBJECTIVE_GEM_ITEM)
                NPC:RemoveItem(hItem)
                if triggerSide == DOTA_TEAM_GOODGUYS then
                    Score.round3.radi_gem_ref = nil
                elseif triggerSide == DOTA_TEAM_BADGUYS then
                    Score.round3.dire_gem_ref = nil
                end
                --TODO: create some sort of summoning effect
                --ParticleManager:CreateParticle("particles/econ/events/ti10/portal/portal_open_good_mesh.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
                GridNav:DestroyTreesAroundPoint( thisEntity:GetOrigin(), 500, false )
                local keeper = CreateUnitByName( ROUND3_BOSS_UNIT, thisEntity:GetOrigin(),        true, nil, nil, DOTA_TEAM_NEUTRALS )
                print("Trying to level keeper abilities up. Has ability points: " .. tostring(keeper:GetAbilityPoints())
                --for ability_key, ability_value in keeper:GetAbilityKeyValues() do
                for i=0,keeper:GetAbilityCount()-1 do
                    local ability = keeper:GetAbilityByIndex(i)
                    local max = 3
                    if(i == keeper:GetAbilityCount()-1) then -- only upgrade ult 3 times
                        max = 2
                    end
                    for j=0, max do
                        print("Leveling ability: " .. ability:GetName())
                        keeper:UpgradeAbility(ability)
                    end
                end
            end
        end
    end
end