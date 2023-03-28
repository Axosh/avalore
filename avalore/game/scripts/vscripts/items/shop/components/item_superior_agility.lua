item_superior_agility = class({})

LinkLuaModifier( "modifier_item_superior_agility", "items/shop/components/item_superior_agility.lua", LUA_MODIFIER_MOTION_NONE )

function item_superior_agility:GetIntrinsicModifierName()
    return "modifier_item_superior_agility"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_superior_agility = modifier_item_superior_agility or class({})

function modifier_item_superior_agility:IsHidden() return true end
function modifier_item_superior_agility:IsDebuff() return false end
function modifier_item_superior_agility:IsPurgable() return false end
function modifier_item_superior_agility:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_superior_agility:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_superior_agility:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_superior_agility:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self:SetStackCount( 1 )
end

function modifier_item_superior_agility:GetModifierBonusStats_Agility()
    return self.bonus_agi * self:GetStackCount()
end