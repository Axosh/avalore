item_lesser_attack_speed = class({})

LinkLuaModifier( "modifier_item_lesser_attack_speed", "items/shop/components/item_lesser_attack_speed.lua", LUA_MODIFIER_MOTION_NONE )

function item_lesser_attack_speed:GetIntrinsicModifierName()
    return "modifier_item_lesser_attack_speed"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_lesser_attack_speed = modifier_item_lesser_attack_speed or class({})

function modifier_item_lesser_attack_speed:IsHidden() return true end
function modifier_item_lesser_attack_speed:IsDebuff() return false end
function modifier_item_lesser_attack_speed:IsPurgable() return false end
function modifier_item_lesser_attack_speed:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_lesser_attack_speed:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_lesser_attack_speed:DeclareFunctions()
    return {    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_lesser_attack_speed:OnCreated(event)
    print("modifier_item_lesser_attack_speed:OnCreated(event)")
    self.item_ability = self:GetAbility()
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self:SetStackCount( 1 )
end

function modifier_item_lesser_attack_speed:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as * self:GetStackCount()
end