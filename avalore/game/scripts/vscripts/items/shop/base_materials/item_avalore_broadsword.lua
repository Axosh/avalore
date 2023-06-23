item_avalore_broadsword = class({})

LinkLuaModifier( "modifier_item_avalore_broadsword", "items/shop/base_materials/item_avalore_broadsword.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_broadsword:GetIntrinsicModifierName()
    return "modifier_item_avalore_broadsword"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_avalore_broadsword = modifier_item_avalore_broadsword or class({})

function modifier_item_avalore_broadsword:IsHidden() return true end
function modifier_item_avalore_broadsword:IsDebuff() return false end
function modifier_item_avalore_broadsword:IsPurgable() return false end
function modifier_item_avalore_broadsword:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_avalore_broadsword:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_avalore_broadsword:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_avalore_broadsword:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_avalore_broadsword:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end