item_amulet_of_agility = class({})

LinkLuaModifier( "modifier_item_amulet_of_agility", "items/shop/tier2/item_amulet_of_agility.lua", LUA_MODIFIER_MOTION_NONE )

function item_amulet_of_agility:GetIntrinsicModifierName()
    return "modifier_item_amulet_of_agility"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_amulet_of_agility = modifier_item_amulet_of_agility or class({})

function modifier_item_amulet_of_agility:IsHidden() return true end
function modifier_item_amulet_of_agility:IsDebuff() return false end
function modifier_item_amulet_of_agility:IsPurgable() return false end
function modifier_item_amulet_of_agility:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_amulet_of_agility:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_amulet_of_agility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_item_amulet_of_agility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_ms_pct = self.item_ability:GetSpecialValueFor("bonus_ms_pct")
end

function modifier_item_amulet_of_agility:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_amulet_of_agility:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_amulet_of_agility:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms_pct
end