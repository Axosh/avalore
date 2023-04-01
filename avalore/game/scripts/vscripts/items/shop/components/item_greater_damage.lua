item_greater_damage = class({})

LinkLuaModifier( "modifier_item_greater_damage", "items/shop/components/item_greater_damage.lua", LUA_MODIFIER_MOTION_NONE )

function item_greater_damage:GetIntrinsicModifierName()
    return "modifier_item_greater_damage"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_greater_damage = modifier_item_greater_damage or class({})

function modifier_item_greater_damage:IsHidden() return true end
function modifier_item_greater_damage:IsDebuff() return false end
function modifier_item_greater_damage:IsPurgable() return false end
function modifier_item_greater_damage:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_greater_damage:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_greater_damage:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_greater_damage:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self:SetStackCount( 1 )
end

function modifier_item_greater_damage:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg * self:GetStackCount()
end