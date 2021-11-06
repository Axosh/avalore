require("references")
require(REQ_UTIL)

ability_fertile_winds_cancel = class({})

function ability_fertile_winds_cancel:GetTexture()
    return "quetzalcoatl/fertile_winds_cancel"
end

function ability_fertile_winds_cancel:OnSpellStart()
    if not IsServer() then return end

    -- -- give back the normal spell
    -- local ability_slot = 0 -- 0-indexed
    -- local spell_in_slot = self:GetCaster():GetAbilityByIndex(ability_slot):GetAbilityName() 
    -- self:GetCaster():SwapAbilities(spell_in_slot, "ability_fertile_winds", false, true)
    -- local curr_level_slot1 = self:GetCaster():FindAbilityByName(spell_in_slot):GetLevel()
    -- self:GetCaster():GetAbilityByIndex(ability_slot):SetLevel(curr_level_slot1)
    -- SwapSpells(self, 1, "ability_fertile_winds")

    -- just remove the modifier, the helper's OnDestroy knows how to swap the normal spell back in
    self:GetCaster():RemoveModifierByName("modifier_fertile_winds_helper")
end