item_hat = class({})

LinkLuaModifier( "modifier_item_hat", "items/shop/base_materials/item_hat.lua", LUA_MODIFIER_MOTION_NONE )

function item_hat:GetIntrinsicModifierName()
    return "modifier_item_hat"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_hat = class({})

function modifier_item_hat:IsHidden() return true end
function modifier_item_hat:IsDebuff() return false end
function modifier_item_hat:IsPurgable() return false end
function modifier_item_hat:RemoveOnDeath() return false end
function modifier_item_hat:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_hat:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_item_hat:OnCreated()
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_hat:GetModifierBonusStats_Intellect()
    return self.bonus_int
end