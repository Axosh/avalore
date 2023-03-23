item_carnyx = class({})

LinkLuaModifier( "modifier_item_carnyx", "items/shop/components/item_carnyx.lua", LUA_MODIFIER_MOTION_NONE )

function item_carnyx:GetIntrinsicModifierName()
    return "modifier_item_carnyx"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_carnyx = modifier_item_carnyx or class({})

function modifier_item_carnyx:IsHidden() return true end
function modifier_item_carnyx:IsDebuff() return false end
function modifier_item_carnyx:IsPurgable() return false end
function modifier_item_carnyx:RemoveOnDeath() return false end

function modifier_item_carnyx:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_item_carnyx:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
end

function modifier_item_carnyx:GetModifierBonusStats_Strength()
    return self.bonus_str
end