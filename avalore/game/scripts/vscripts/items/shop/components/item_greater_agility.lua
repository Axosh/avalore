item_greater_agility = class({})

LinkLuaModifier( "modifier_item_greater_agility", "items/shop/components/item_greater_agility.lua", LUA_MODIFIER_MOTION_NONE )

function item_greater_agility:GetIntrinsicModifierName()
    return "modifier_item_greater_agility"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_greater_agility = modifier_item_greater_agility or class({})

function modifier_item_greater_agility:IsHidden() return true end
function modifier_item_greater_agility:IsDebuff() return false end
function modifier_item_greater_agility:IsPurgable() return false end
function modifier_item_greater_agility:RemoveOnDeath() return false end

function modifier_item_greater_agility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_greater_agility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end

function modifier_item_greater_agility:GetModifierBonusStats_Agility()
    return self.bonus_agi
end