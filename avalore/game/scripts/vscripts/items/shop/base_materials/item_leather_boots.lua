item_leather_boots = class({})

LinkLuaModifier( "modifier_item_leather_boots", "items/shop/base_materials/item_leather_boots.lua", LUA_MODIFIER_MOTION_NONE )

function item_leather_boots:GetIntrinsicModifierName()
    return "modifier_item_leather_boots"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_leather_boots = modifier_item_leather_boots or class({})

function modifier_item_leather_boots:IsHidden() return true end
function modifier_item_leather_boots:IsDebuff() return false end
function modifier_item_leather_boots:IsPurgable() return false end
function modifier_item_leather_boots:RemoveOnDeath() return false end
function modifier_item_leather_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_leather_boots:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_item_leather_boots:OnCreated(event)
    self.item_ability = self:GetAbility()
    print("modifier_item_leather_boots:OnCreated >> " .. self:GetAbility():GetName())
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_leather_boots:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end