item_lesser_agility = class({})

LinkLuaModifier( "modifier_item_lesser_agility", "items/shop/components/item_lesser_agility.lua", LUA_MODIFIER_MOTION_NONE )

function item_lesser_agility:GetIntrinsicModifierName()
    return "modifier_item_lesser_agility"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_lesser_agility = modifier_item_lesser_agility or class({})

function modifier_item_lesser_agility:IsHidden() return true end
function modifier_item_lesser_agility:IsDebuff() return false end
function modifier_item_lesser_agility:IsPurgable() return false end
function modifier_item_lesser_agility:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_lesser_agility:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lesser_agility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_lesser_agility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self:SetStackCount( 1 )
end

function modifier_item_lesser_agility:GetModifierBonusStats_Agility()
    return self.bonus_agi * self:GetStackCount()
end