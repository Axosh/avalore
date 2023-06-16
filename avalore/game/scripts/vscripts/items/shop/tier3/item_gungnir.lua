item_gungnir = class({})

LinkLuaModifier( "modifier_item_gungnir", "items/shop/tier3/item_gungnir.lua", LUA_MODIFIER_MOTION_NONE )

function item_gungnir:GetIntrinsicModifierName()
    return "modifier_item_gungnir"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_gungnir = modifier_item_gungnir or class({})

function modifier_item_gungnir:IsHidden() return true end
function modifier_item_gungnir:IsDebuff() return false end
function modifier_item_gungnir:IsPurgable() return false end
function modifier_item_gungnir:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_gungnir:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_gungnir:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_item_gungnir:CheckState()
    return {
        [MODIFIER_STATE_CANNOT_MISS] = true
    }
end

function modifier_item_gungnir:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_range = self.item_ability:GetSpecialValueFor("bonus_range")
end

function modifier_item_gungnir:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_gungnir:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_gungnir:GetModifierAttackRangeBonus()
    return self.bonus_range
end