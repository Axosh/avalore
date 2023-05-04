item_avalore_bracer = class({})

LinkLuaModifier( "modifier_item_avalore_bracer", "items/shop/base_materials/item_avalore_bracer.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_bracer:GetIntrinsicModifierName()
    return "modifier_item_avalore_bracer"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_avalore_bracer = modifier_item_avalore_bracer or class({})

function modifier_item_avalore_bracer:IsHidden() return true end
function modifier_item_avalore_bracer:IsDebuff() return false end
function modifier_item_avalore_bracer:IsPurgable() return false end
function modifier_item_avalore_bracer:RemoveOnDeath() return false end

function modifier_item_avalore_bracer:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_avalore_bracer:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_avalore_bracer:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_avalore_bracer:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_avalore_bracer:GetModifierBonusStats_Intellect()
    return self.bonus_int
end