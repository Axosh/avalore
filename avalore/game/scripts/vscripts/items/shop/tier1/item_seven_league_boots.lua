item_seven_league_boots = class({})

LinkLuaModifier( "modifier_item_seven_league_boots", "items/shop/tier1/item_seven_league_boots.lua", LUA_MODIFIER_MOTION_NONE )

function item_seven_league_boots:GetIntrinsicModifierName()
    return "modifier_item_seven_league_boots"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_seven_league_boots = modifier_item_seven_league_boots or class({})

function modifier_item_seven_league_boots:IsHidden()      return true  end
function modifier_item_seven_league_boots:IsDebuff()      return false end
function modifier_item_seven_league_boots:IsPurgable()    return false end
function modifier_item_seven_league_boots:RemoveOnDeath() return false end
function modifier_item_seven_league_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_seven_league_boots:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_seven_league_boots:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_seven_league_boots:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_seven_league_boots:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end