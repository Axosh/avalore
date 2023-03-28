item_superior_strength = class({})

LinkLuaModifier( "modifier_item_superior_strength", "items/shop/components/item_superior_strength.lua", LUA_MODIFIER_MOTION_NONE )

function item_superior_strength:GetIntrinsicModifierName()
    return "modifier_item_superior_strength"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_superior_strength = modifier_item_superior_strength or class({})

function modifier_item_superior_strength:IsHidden() return true end
function modifier_item_superior_strength:IsDebuff() return false end
function modifier_item_superior_strength:IsPurgable() return false end
function modifier_item_superior_strength:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_superior_strength:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_superior_strength:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_item_superior_strength:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self:SetStackCount( 1 )
end

function modifier_item_superior_strength:GetModifierBonusStats_Strength()
    return self.bonus_str * self:GetStackCount()
end