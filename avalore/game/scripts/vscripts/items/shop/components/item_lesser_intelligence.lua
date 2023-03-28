item_lesser_intelligence = class({})

LinkLuaModifier( "modifier_item_lesser_intelligence", "items/shop/components/item_lesser_intelligence.lua", LUA_MODIFIER_MOTION_NONE )

function item_lesser_intelligence:GetIntrinsicModifierName()
    return "modifier_item_lesser_intelligence"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_lesser_intelligence = modifier_item_lesser_intelligence or class({})

function modifier_item_lesser_intelligence:IsHidden() return true end
function modifier_item_lesser_intelligence:IsDebuff() return false end
function modifier_item_lesser_intelligence:IsPurgable() return false end
function modifier_item_lesser_intelligence:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_lesser_intelligence:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lesser_intelligence:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_lesser_intelligence:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self:SetStackCount( 1 )
end

function modifier_item_lesser_intelligence:GetModifierBonusStats_Intellect()
    return self.bonus_int * self:GetStackCount()
end