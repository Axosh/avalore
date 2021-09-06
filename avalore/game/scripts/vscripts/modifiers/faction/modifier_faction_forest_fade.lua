modifier_faction_forest_fade = class ({})

function modifier_faction_forest_fade:GetTexture()
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
    if not IsServer() then return end
    if kv.isCosmetic then
        -- if we're a cosmetic, try to keep up with the stack count on the hero (particularly because Robin Hood can change cosmetics)
        if self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()) then
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()):GetStackCount()
        else
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName("modifier_faction_forest"):GetStackCount()
        end
    else
        self.cooldown = 5 - self:GetParent():FindModifierByName("modifier_faction_forest"):GetStackCount()
    end
    
	--local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    --ParticleManager:ReleaseParticleIndex(particle)
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
function modifier_faction_forest_fade:OnAbilityFullyCast(keys)
    if not IsServer() then return end

    local caster = keys.unit
    -- Only apply if the parent is the one attacking
    if self:GetParent() == caster then
        self:SetStackCount(self.cooldown)
    end
end

function modifier_faction_forest_fade:OnIntervalThink()
    if not IsServer() then return end

    local stacks = self:GetStackCount()
    if stacks > 0 then
        self:SetStackCount(stacks - 1)
        if (stacks - 1 ) == 0 then
            local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
    
end