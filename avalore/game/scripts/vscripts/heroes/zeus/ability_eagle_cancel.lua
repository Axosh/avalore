require("references")
require(REQ_UTIL)

ability_eagle_cancel = class({})

function ability_eagle_cancel:GetTexture()
    return "zeus/cancel_eagle"
end

function ability_eagle_cancel:OnSpellStart()
    if not IsServer() then return end

    -- give back the normal spell
    local spell_slot1 = self:GetCaster():GetAbilityByIndex(1):GetAbilityName() -- 0-indexed
    self:GetCaster():SwapAbilities(spell_slot1, "ability_shapeshift", false, true)
    local curr_level_slot1 = self:GetCaster():FindAbilityByName(spell_slot1):GetLevel()
    self:GetCaster():GetAbilityByIndex(1):SetLevel(curr_level_slot1)
    SwapSpells(self, 1, "ability_shapeshift")

    self:GetCaster():RemoveModifierByName("modifier_shapeshift_eagle")
end