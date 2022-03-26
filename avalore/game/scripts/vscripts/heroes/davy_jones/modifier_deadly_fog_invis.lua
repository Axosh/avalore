modifier_deadly_fog_invis = class({})

function modifier_deadly_fog_invis:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_deadly_fog_invis:IsHidden() return false end
function modifier_deadly_fog_invis:IsPurgable() return false end
function modifier_deadly_fog_invis:IsDebuff() return false end

function modifier_deadly_fog_invis:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_deadly_fog_invis:GetModifierInvisibilityLevel()
    if self:GetStackCount() == 0 then
        return 1 -- invis
    else
        return 0 -- visible
    end
end

function modifier_deadly_fog_invis:CheckState()
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

function modifier_deadly_fog_invis:GetPriority()
    return MODIFIER_PRIORITY_NORMAL
end

function modifier_deadly_fog_invis:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
    self.invis_fade = self:GetAbility():GetSpecialValueFor("invis_fade_time")

	local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
    self:SetStackCount(0) -- start out invis when trigger the spell
    self:StartIntervalThink( 1 )
end

function modifier_deadly_fog_invis:OnAttack(keys)
    if IsServer() then
        local attacker = keys.attacker
        -- Only apply if the parent is the one attacking
        if self.parent == attacker then
            --print("[modifier_deadly_fog_invis] OnAttack")
            self:SetStackCount(self.invis_fade)
        end
    end
end

function modifier_deadly_fog_invis:OnAbilityFullyCast(keys)
    if IsServer() then
        local caster = keys.unit
        -- Only apply if the parent is the one attacking
        if self.parent == caster then
            self:SetStackCount(self.invis_fade)
        end
    end
end

function modifier_deadly_fog_invis:OnIntervalThink()
    if IsServer() then
        local stacks = self:GetStackCount()
        if stacks > 0 then
            self:SetStackCount(stacks - 1)
            if (stacks - 1 ) == 0 then
                local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN, self:GetParent())
                ParticleManager:ReleaseParticleIndex(particle)
            end
        end
    end
end