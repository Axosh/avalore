modifier_faction_forest = class({})

-- stacks with self based on how many allies have it
function modifier_faction_forest:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_forest:IsHidden() return false end
function modifier_faction_forest:IsDebuff() return false end
function modifier_faction_forest:IsPurgable() return false end
function modifier_faction_forest:RemoveOnDeath() return false end

function modifier_faction_forest:GetTexture()
    return "modifier_faction_forest"
end

function modifier_faction_forest:DeclareFunctions()
    return {
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end

function modifier_faction_forest:OnCreated(kv)
    local player_team = self:GetParent():GetTeam()
    -- find how many allied heroes are part of this alliance
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero:GetTeam() == NPC:GetTeam() then
                    if (mod_name == MODIFIER_FLAG_MORALE_NAME and hero:FindModifierByName(MODIFIER_FLAG_MORALE_NAME)) then
                        print("Found instance of morale aura - Incrementing stack count")
                        hero:FindModifierByName(MODIFIER_FLAG_MORALE_NAME):IncrementStackCount()
                    else
                        print("Adding modifier " .. mod_name .. " for hero " .. hero:GetName())
                        hero:AddNewModifier(hero, nil, mod_name, {})
                    end
                end
            end
        end
    end
end