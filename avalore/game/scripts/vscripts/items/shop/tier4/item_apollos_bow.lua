item_apollos_bow = class({})

LinkLuaModifier( "modifier_item_apollos_bow", "items/shop/tier4/item_apollos_bow.lua", LUA_MODIFIER_MOTION_NONE )

function item_apollos_bow:GetIntrinsicModifierName()
    return "modifier_item_apollos_bow"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_apollos_bow = modifier_item_apollos_bow or class({})

function modifier_item_apollos_bow:IsHidden() return true end
function modifier_item_apollos_bow:IsDebuff() return false end
function modifier_item_apollos_bow:IsPurgable() return false end
function modifier_item_apollos_bow:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
--function modifier_item_apollos_bow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_apollos_bow:DeclareFunctions()
    return {    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_apollos_bow:OnCreated(event)
    print("modifier_item_apollos_bow:OnCreated(event)")
    self.item_ability = self:GetAbility()
    self.bonus_range = self.item_ability:GetSpecialValueFor("bonus_range")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end

function modifier_item_apollos_bow:GetModifierAttackRangeBonus()
    if self:GetParent():IsRangedAttacker() then
        return self.bonus_range
    end
end

function modifier_item_apollos_bow:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_apollos_bow:GetModifierBonusStats_Agility()
    return self.bonus_agi
end