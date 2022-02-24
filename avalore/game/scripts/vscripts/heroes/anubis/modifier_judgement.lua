modifier_judgement = class({})

function modifier_judgement:IsHidden() return false end
function modifier_judgement:IsPurgable() return false end
function modifier_judgement:RemoveOnDeath() return true end

function modifier_judgement:OnCreated(kv)
    self.max_dmg = self:GetAbility():GetSpecialValueFor("max_damage")
    self.max_heal = self:GetAbility():GetSpecialValueFor("max_healing")

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_heartpiercer_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:AddParticle(self.particle, false, false, -1, true, true)

    if not IsServer() then return end
    self.damage_taken_counter = 1 -- default to healing if neither happens
    self.damage_given_count = 0
end

function modifier_judgement:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_judgement:GetModifierIncomingDamage_Percentage(kv)
    if keys.attacker and self:GetRemainingTime() >= 0 then
        self.damage_taken_counter = self.damage_taken_counter + keys.damage
    end
end