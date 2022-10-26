item_sandals = class({})

LinkLuaModifier( "modifier_item_sandals", "items/shop/base_materials/item_sandals.lua", LUA_MODIFIER_MOTION_NONE )

function item_sandals:GetIntrinsicModifierName()
    return "modifier_item_sandals"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_sandals = class({})

function modifier_item_sandals:IsHidden()       return true  end
function modifier_item_sandals:IsDebuff()       return false end
function modifier_item_sandals:IsPurgable()     return false end
function modifier_item_sandals:RemoveOnDeath()  return false end
-- function modifier_item_sandals:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_item_sandals:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_sandals:OnCreated()
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_sandals:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_sandals:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end