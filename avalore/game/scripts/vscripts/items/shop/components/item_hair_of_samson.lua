item_hair_of_samson = class({})

LinkLuaModifier( "modifier_item_hair_of_samson", "items/shop/components/item_hair_of_samson.lua", LUA_MODIFIER_MOTION_NONE )

function item_hair_of_samson:GetIntrinsicModifierName()
    return "modifier_item_hair_of_samson"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_hair_of_samson = modifier_item_hair_of_samson or class({})

function modifier_item_hair_of_samson:IsHidden() return true end
function modifier_item_hair_of_samson:IsDebuff() return false end
function modifier_item_hair_of_samson:IsPurgable() return false end
function modifier_item_hair_of_samson:RemoveOnDeath() return false end

function modifier_item_hair_of_samson:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_item_hair_of_samson:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
end

function modifier_item_hair_of_samson:GetModifierBonusStats_Strength()
    return self.bonus_str
end