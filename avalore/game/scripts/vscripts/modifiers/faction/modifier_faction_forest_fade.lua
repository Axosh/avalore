modifier_faction_forest_fade = class ({})

function modifier_faction_forest:GetTexture()
    return "modifier_faction_forest_fade"
end

function modifier_faction_forest_fade:IsHidden() return false end
function modifier_faction_forest_fade:IsPurgable() return false end

function modifier_faction_forest_fade:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end
    
function modifier_faction_forest_fade:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 0 then
        return 1 -- invis
    else
        return 0 -- visible
    end
end

function modifier_faction_forest_fade:CheckState()
    if IsServer() then
        if self:GetStackCount() == 0 then
            return  {   [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                        [MODIFIER_STATE_INVISIBLE] = true
                    }
        else
            return  {   [MODIFIER_STATE_NO_UNIT_COLLISION] = false,
                        [MODIFIER_STATE_INVISIBLE] = false
                    }
        end
    end
end

function modifier_faction_forest_fade:OnCreated(kv)
    self.cooldown = kv.cooldown
	local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
    self:SetStackCount(self.cooldown)
    self:StartIntervalThink( 1 )
end

-- break on right-click attack
function modifier_faction_forest_fade:OnAttack(keys)
    if not IsServer() then return end

    local attacker = keys.attacker
    -- Only apply if the parent is the one attacking
    if self:GetParent() == attacker then
        self:SetStackCount(self.cooldown)
    end
    
end

-- break on spell cast
function modifier_deadly_fog_invis:OnAbilityFullyCast(keys)
    if not IsServer() then return end

    local caster = keys.unit
    -- Only apply if the parent is the one attacking
    if self.GetParent() == caster then
        self:SetStackCount(self.cooldown)
    end
end
