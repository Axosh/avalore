item_adder_stone = class({})

LinkLuaModifier( "modifier_item_adder_stone", "items/shop/components/item_adder_stone.lua", LUA_MODIFIER_MOTION_NONE )

function item_adder_stone:GetIntrinsicModifierName()
    return "modifier_item_adder_stone"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_adder_stone = modifier_item_adder_stone or class({})

function modifier_item_adder_stone:IsHidden() return true end
function modifier_item_adder_stone:IsDebuff() return false end
function modifier_item_adder_stone:IsPurgable() return false end
function modifier_item_adder_stone:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_adder_stone:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_adder_stone:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_item_adder_stone:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self.magic_resist = self.item_ability:GetSpecialValueFor("magic_resist")
    self.bonus_hp_regen = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_adder_stone:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_adder_stone:GetModifierMagicalResistanceBonus()
    return self.magic_resist
end

function modifier_item_adder_stone:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end