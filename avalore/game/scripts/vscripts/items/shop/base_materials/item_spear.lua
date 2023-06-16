item_spear = class({})

LinkLuaModifier( "modifier_item_spear", "items/shop/base_materials/item_spear.lua", LUA_MODIFIER_MOTION_NONE )

function item_spear:GetIntrinsicModifierName()
    return "modifier_item_spear"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_spear = modifier_item_spear or class({})

function modifier_item_spear:IsHidden() return true end
function modifier_item_spear:IsDebuff() return false end
function modifier_item_spear:IsPurgable() return false end
function modifier_item_spear:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_spear:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_spear:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_spear:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
end

function modifier_item_spear:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_spear:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end