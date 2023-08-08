item_glaive = class({})

LinkLuaModifier( "modifier_item_glaive", "items/shop/components/item_glaive.lua", LUA_MODIFIER_MOTION_NONE )

function item_glaive:GetIntrinsicModifierName()
    return "modifier_item_glaive"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_glaive = modifier_item_glaive or class({})

function modifier_item_glaive:IsHidden() return true end
function modifier_item_glaive:IsDebuff() return false end
function modifier_item_glaive:IsPurgable() return false end
function modifier_item_glaive:RemoveOnDeath() return false end

function modifier_item_glaive:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK }
end

function modifier_item_glaive:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.damage_block = self.item_ability:GetSpecialValueFor("damage_block")
end

function modifier_item_glaive:GetModifierPhysical_ConstantBlock()
	return self.damage_block
end