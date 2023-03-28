item_greater_strength = class({})

LinkLuaModifier( "modifier_item_greater_strength", "items/shop/components/item_greater_strength.lua", LUA_MODIFIER_MOTION_NONE )

function item_greater_strength:GetIntrinsicModifierName()
    return "modifier_item_greater_strength"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_greater_strength = modifier_item_greater_strength or class({})

function modifier_item_greater_strength:IsHidden() return true end
function modifier_item_greater_strength:IsDebuff() return false end
function modifier_item_greater_strength:IsPurgable() return false end
function modifier_item_greater_strength:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_greater_strength:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_greater_strength:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_item_greater_strength:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self:SetStackCount( 1 )
end

function modifier_item_greater_strength:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end