item_wooden_shield = class({})

LinkLuaModifier( "modifier_item_wooden_shield", "items/shop/base_materials/item_wooden_shield.lua", LUA_MODIFIER_MOTION_NONE )

function item_wooden_shield:GetIntrinsicModifierName()
    return "modifier_item_wooden_shield"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_wooden_shield = modifier_item_wooden_shield or class({})

function modifier_item_wooden_shield:IsHidden() return true end
function modifier_item_wooden_shield:IsDebuff() return false end
function modifier_item_wooden_shield:IsPurgable() return false end
function modifier_item_wooden_shield:RemoveOnDeath() return false end

function modifier_item_wooden_shield:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK }
end

function modifier_item_wooden_shield:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.damage_block = self.item_ability:GetSpecialValueFor("damage_block")
end

function modifier_item_wooden_shield:GetModifierPhysical_ConstantBlock()
	return self.damage_block
end