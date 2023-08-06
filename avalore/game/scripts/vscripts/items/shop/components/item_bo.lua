item_bo = class({})

LinkLuaModifier( "modifier_item_bo", "items/shop/components/item_bo.lua", LUA_MODIFIER_MOTION_NONE )

function item_bo:GetIntrinsicModifierName()
    return "modifier_item_bo"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_bo = modifier_item_bo or class({})

function modifier_item_bo:IsHidden() return true end
function modifier_item_bo:IsDebuff() return false end
function modifier_item_bo:IsPurgable() return false end
function modifier_item_bo:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
--function modifier_item_bo:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_bo:DeclareFunctions()
    return {    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_item_bo:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_range = self.item_ability:GetSpecialValueFor("bonus_range")
    --self:SetStackCount( 1 )
end

function modifier_item_bo:GetModifierAttackRangeBonus()
    if not self:GetParent():IsRangedAttacker() then
        return self.bonus_range --* self:GetStackCount()
    end
end