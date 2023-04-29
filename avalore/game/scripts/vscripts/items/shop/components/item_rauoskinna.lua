item_rauoskinna = class({})

LinkLuaModifier( "modifier_item_rauoskinna", "items/shop/components/item_rauoskinna.lua", LUA_MODIFIER_MOTION_NONE )

function item_rauoskinna:GetIntrinsicModifierName()
    return "modifier_item_rauoskinna"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_rauoskinna = modifier_item_rauoskinna or class({})

function modifier_item_rauoskinna:IsHidden() return true end
function modifier_item_rauoskinna:IsDebuff() return false end
function modifier_item_rauoskinna:IsPurgable() return false end
function modifier_item_rauoskinna:RemoveOnDeath() return false end

function modifier_item_rauoskinna:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MANA_BONUS }
end

function modifier_item_rauoskinna:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_mana = self.item_ability:GetSpecialValueFor("bonus_mana")
    self:SetStackCount( 1 )
end

function modifier_item_rauoskinna:GetModifierManaBonus()
    return self.bonus_mana * self:GetStackCount()
end