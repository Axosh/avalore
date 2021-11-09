modifier_quetzalcoatls_blessing = class({})

function modifier_quetzalcoatls_blessing:IsHidden() return false end
function modifier_quetzalcoatls_blessing:IsPurgable() return false end
function modifier_quetzalcoatls_blessing:RemoveOnDeath() return true end

function modifier_quetzalcoatls_blessing:OnCreated( kv )
    self.int_bonus = self:GetAbility():GetSpecialValueFor("int_bonus")
    self.magic_amp = self:GetAbility():GetSpecialValueFor("magic_amp")
    self.respawn_reduction_percent = (self:GetAbility():GetSpecialValueFor("respawn_reduction_percent") / 100)

    self.particle = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_focusfire_wind_tube_pnt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
    self:AddParticle(self.particle, false, false, -1, false, false)
end

function modifier_quetzalcoatls_blessing:OnRefresh( kv )
    self.int_bonus = self:GetAbility():GetSpecialValueFor("int_bonus")
    self.magic_amp = self:GetAbility():GetSpecialValueFor("magic_amp")
    self.respawn_reduction_percent = self:GetAbility():GetSpecialValueFor("respawn_reduction_percent")
end

function modifier_quetzalcoatls_blessing:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE
        --MODIFIER_PROPERTY_RESPAWNTIME -- placeholder in case we need to switch
    }
end

function modifier_quetzalcoatls_blessing:GetModifierPercentageRespawnTime()
    return self.respawn_reduction_percent
end

function modifier_quetzalcoatls_blessing:GetModifierBonusStats_Intellect()
    return self.int_bonus
end

function modifier_quetzalcoatls_blessing:GetModifierSpellAmplify_Percentage()
    return self.magic_amp
end