item_war_belt = class({})

LinkLuaModifier( "modifier_item_war_belt", "items/shop/base_materials/item_war_belt.lua", LUA_MODIFIER_MOTION_NONE )

function item_war_belt:GetIntrinsicModifierName()
    return "modifier_item_war_belt"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_war_belt = modifier_item_war_belt or class({})

function modifier_item_war_belt:IsHidden() return true end
function modifier_item_war_belt:IsDebuff() return false end
function modifier_item_war_belt:IsPurgable() return false end
function modifier_item_war_belt:RemoveOnDeath() return false end

function modifier_item_war_belt:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_war_belt:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end

function modifier_item_war_belt:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_war_belt:GetModifierBonusStats_Agility()
    return self.bonus_agi
end