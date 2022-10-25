item_gambeson = class({})

LinkLuaModifier( "modifier_item_gambeson", "items/shop/base_materials/item_gambeson.lua", LUA_MODIFIER_MOTION_NONE )

function item_gambeson:GetIntrinsicModifierName()
    return "modifier_item_gambeson"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_gambeson = class({})

function modifier_item_gambeson:IsHidden() return true end
function modifier_item_gambeson:IsDebuff() return false end
function modifier_item_gambeson:IsPurgable() return false end
function modifier_item_gambeson:RemoveOnDeath() return false end
function modifier_item_gambeson:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_gambeson:DeclareFunctions()
    return { MODIFIER_PROPERTY_STATS_AGILITY_BONUS }
end

function modifier_item_gambeson:OnCreated()
    self.item_ability = self:GetAbility()
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
end

function modifier_item_gambeson:GetModifierBonusStats_Agility()
    return self.bonus_agi
end