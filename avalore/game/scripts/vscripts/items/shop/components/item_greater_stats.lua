item_greater_stats = class({})

LinkLuaModifier( "modifier_item_greater_stats", "items/shop/components/item_greater_stats.lua", LUA_MODIFIER_MOTION_NONE )

function item_greater_stats:GetIntrinsicModifierName()
    return "modifier_item_greater_stats"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_greater_stats = modifier_item_greater_stats or class({})

function modifier_item_greater_stats:IsHidden() return true end
function modifier_item_greater_stats:IsDebuff() return false end
function modifier_item_greater_stats:IsPurgable() return false end
function modifier_item_greater_stats:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_greater_stats:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_greater_stats:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_greater_stats:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self:SetStackCount( 1 )
end

function modifier_item_greater_stats:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end

function modifier_item_greater_stats:GetModifierBonusStats_Agility()
    return self.bonus_agi * self:GetStackCount()
end

function modifier_item_greater_stats:GetModifierBonusStats_Intellect()
    return self.bonus_int * self:GetStackCount()
end