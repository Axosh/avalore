item_greater_mana_regen = class({})

LinkLuaModifier( "modifier_item_greater_mana_regen", "items/shop/components/item_greater_mana_regen.lua", LUA_MODIFIER_MOTION_NONE )

function item_greater_mana_regen:GetIntrinsicModifierName()
    return "modifier_item_greater_mana_regen"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_greater_mana_regen = modifier_item_greater_mana_regen or class({})

function modifier_item_greater_mana_regen:IsHidden() return true end
function modifier_item_greater_mana_regen:IsDebuff() return false end
function modifier_item_greater_mana_regen:IsPurgable() return false end
function modifier_item_greater_mana_regen:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_greater_mana_regen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_greater_mana_regen:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_greater_mana_regen:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self:SetStackCount( 1 )
end

function modifier_item_greater_mana_regen:GetModifierConstantManaRegen()
    return self.bonus_mana_regen * self:GetStackCount()
end