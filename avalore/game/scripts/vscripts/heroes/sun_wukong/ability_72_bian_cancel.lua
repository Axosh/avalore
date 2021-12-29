require("references")
require(REQ_UTIL)

ability_72_bian_cancel = class({})

function ability_72_bian_cancel:GetTexture()
    return "sun_wukong/monkey_form"
end

function ability_72_bian_cancel:OnSpellStart()
    if not IsServer() then return end

    -- give back the normal spell
    local spell_slot2 = self:GetCaster():GetAbilityByIndex(2):GetAbilityName() -- 0-indexed
    self:GetCaster():SwapAbilities(spell_slot2, "ability_72_bian", false, true)
    local curr_level_slot2 = self:GetCaster():FindAbilityByName(spell_slot2):GetLevel()
    self:GetCaster():GetAbilityByIndex(2):SetLevel(curr_level_slot2)
    SwapSpells(self, 2, "ability_72_bian")

    self:GetCaster():RemoveModifierByName("modifier_72_bian_bird")
    self:GetCaster():RemoveModifierByName("modifier_72_bian_boar")
    self:GetCaster():RemoveModifierByName("modifier_72_bian_tree")
    self:GetCaster():RemoveModifierByName("modifier_72_bian_fish")

    local particle_revert = "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf"
    local particle_revert_fx = ParticleManager:CreateParticle(particle_revert, PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle_revert_fx, 0, self:GetCaster():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_revert_fx, 3, self:GetCaster():GetAbsOrigin())
end