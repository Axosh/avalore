modifier_water_fade = class({})

function modifier_water_fade:GetTexture()
    return "generic/water_fade"
end

function modifier_water_fade:IsHidden() return false end
function modifier_water_fade:IsPurgable() return false end

function modifier_water_fade:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_water_fade:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 0 then
        return 1 -- invis
    else
        return 0 -- visible
    end
end

function modifier_water_fade:CheckState()
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

function modifier_water_fade:OnCreated(kv)
    if not IsServer() then return end

    if kv.isCosmetic then
        -- if we're a cosmetic, try to keep up with the stack count on the hero (particularly because Robin Hood can change cosmetics)
        if self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()) then
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName(self:GetName()):GetStackCount()
        else
            self.cooldown = self:GetCaster():GetOwnerEntity():FindModifierByName("modifier_water_fade"):GetStackCount()
        end
    else
        if kv.stacks_max then
            self.cooldown = kv.stacks_max
        else
            self.cooldown = 3
        end
        --self.cooldown = 5 - self:GetParent():FindModifierByName("modifier_water_fade"):GetStackCount()
    end
    
	--local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    --ParticleManager:ReleaseParticleIndex(particle)
    self:SetStackCount(self.cooldown)
    self:StartIntervalThink( 1 )
end

-- break on right-click attack
function modifier_water_fade:OnAttack(keys)
    if not IsServer() then return end

    local attacker = keys.attacker
    -- Only apply if the parent is the one attacking
    if self:GetParent() == attacker then
        self:SetStackCount(self.cooldown)
    end
    
end

-- break on spell cast
function modifier_water_fade:OnAbilityFullyCast(keys)
    if not IsServer() then return end

    local caster = keys.unit
    -- Only apply if the parent is the one attacking
    if self:GetParent() == caster then
        self:SetStackCount(self.cooldown)
    end
end

function modifier_water_fade:OnIntervalThink()
    if not IsServer() then return end

    local stacks = self:GetStackCount()
    if stacks > 0 and self:GetParent():GetAbsOrigin().z <=0.5 then
        self:SetStackCount(stacks - 1)
        if (stacks - 1 ) == 0 then
            local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
            ParticleManager:ReleaseParticleIndex(particle)
        end
    elseif self:GetParent():GetAbsOrigin().z > 0.5 then
        self:SetStackCount(self.cooldown)
    else

    end
    
end