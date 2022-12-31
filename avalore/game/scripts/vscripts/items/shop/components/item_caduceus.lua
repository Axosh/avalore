item_caduceus = class({})

LinkLuaModifier( "modifier_item_caduceus", "items/shop/components/item_caduceus.lua", LUA_MODIFIER_MOTION_NONE )

function item_caduceus:GetIntrinsicModifierName()
    return "modifier_item_caduceus"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_caduceus = modifier_item_caduceus or class({})

function modifier_item_caduceus:IsHidden() return true end
function modifier_item_caduceus:IsDebuff() return false end
function modifier_item_caduceus:IsPurgable() return false end
function modifier_item_caduceus:RemoveOnDeath() return false end
function modifier_item_caduceus:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_caduceus:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_item_caduceus:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_caduceus:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end
