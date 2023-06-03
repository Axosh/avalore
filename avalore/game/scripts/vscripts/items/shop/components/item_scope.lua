item_scope = class({})

LinkLuaModifier( "modifier_item_scope", "items/shop/components/item_scope.lua", LUA_MODIFIER_MOTION_NONE )

function item_scope:GetIntrinsicModifierName()
    return "modifier_item_scope"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_scope = modifier_item_scope or class({})

function modifier_item_scope:IsHidden() return true end
function modifier_item_scope:IsDebuff() return false end
function modifier_item_scope:IsPurgable() return false end
function modifier_item_scope:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
--function modifier_item_scope:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_scope:DeclareFunctions()
    return {    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_item_scope:OnCreated(event)
    print("modifier_item_scope:OnCreated(event)")
    self.item_ability = self:GetAbility()
    self.bonus_range = self.item_ability:GetSpecialValueFor("bonus_range")
    --self:SetStackCount( 1 )
end

function modifier_item_scope:GetModifierAttackRangeBonus()
    if self:GetParent():IsRangedAttacker() then
        return self.bonus_range --* self:GetStackCount()
    end
end