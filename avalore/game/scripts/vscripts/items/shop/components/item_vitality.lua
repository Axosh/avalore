item_vitality = class({})

LinkLuaModifier( "modifier_item_vitality", "items/shop/components/item_vitality.lua", LUA_MODIFIER_MOTION_NONE )

function item_vitality:GetIntrinsicModifierName()
    return "modifier_item_vitality"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_vitality = modifier_item_vitality or class({})

function modifier_item_vitality:IsHidden() return true end
function modifier_item_vitality:IsDebuff() return false end
function modifier_item_vitality:IsPurgable() return false end
function modifier_item_vitality:RemoveOnDeath() return false end

function modifier_item_vitality:DeclareFunctions()
    return {    MODIFIER_PROPERTY_HEALTH_BONUS }
end

function modifier_item_vitality:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_hp = self.item_ability:GetSpecialValueFor("bonus_hp")
end

function modifier_item_vitality:GetModifierHealthBonus()
    return self.bonus_hp
end