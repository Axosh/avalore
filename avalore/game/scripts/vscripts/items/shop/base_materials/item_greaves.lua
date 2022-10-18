item_greaves = class({})

LinkLuaModifier( "modifier_item_greaves", "items/shop/base_materials/item_greaves.lua", LUA_MODIFIER_MOTION_NONE )

function item_greaves:GetIntrinsicModifierName()
    return "modifier_item_greaves"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_greaves = modifier_item_greaves or class({})

function modifier_item_greaves:IsHidden() return true end
function modifier_item_greaves:IsDebuff() return false end
function modifier_item_greaves:IsPurgable() return false end
function modifier_item_greaves:RemoveOnDeath() return false end
function modifier_item_greaves:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_greaves:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_greaves:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_greaves:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_greaves:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end