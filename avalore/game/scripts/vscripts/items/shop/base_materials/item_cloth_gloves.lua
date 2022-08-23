item_cloth_gloves = class({})

LinkLuaModifier( "modifier_item_cloth_gloves", "items/shop/base_materials/item_cloth_gloves.lua", LUA_MODIFIER_MOTION_NONE )

function item_cloth_gloves:GetIntrinsicModifierName()
    return "modifier_item_cloth_gloves"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_cloth_gloves = modifier_item_cloth_gloves or class({})

function modifier_item_cloth_gloves:IsHidden() return true end
function modifier_item_cloth_gloves:IsDebuff() return false end
function modifier_item_cloth_gloves:IsPurgable() return false end
function modifier_item_cloth_gloves:RemoveOnDeath() return false end

function modifier_item_cloth_gloves:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_cloth_gloves:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_cloth_gloves:GetModifierBonusStats_Intellect()
    return self.bonus_int
end