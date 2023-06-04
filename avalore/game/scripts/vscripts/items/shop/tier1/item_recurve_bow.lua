item_recurve_bow = class({})

LinkLuaModifier( "modifier_item_recurve_bow", "items/shop/tier1/item_recurve_bow.lua", LUA_MODIFIER_MOTION_NONE )

function item_recurve_bow:GetIntrinsicModifierName()
    return "modifier_item_recurve_bow"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_recurve_bow = modifier_item_recurve_bow or class({})

function modifier_item_recurve_bow:IsHidden() return true end
function modifier_item_recurve_bow:IsDebuff() return false end
function modifier_item_recurve_bow:IsPurgable() return false end
function modifier_item_recurve_bow:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
--function modifier_item_recurve_bow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_recurve_bow:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_recurve_bow:OnCreated(event)
    --print("modifier_item_recurve_bow:OnCreated(event)")
    self.item_ability = self:GetAbility()
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end


function modifier_item_recurve_bow:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_recurve_bow:GetModifierBonusStats_Agility()
    return self.bonus_agi
end