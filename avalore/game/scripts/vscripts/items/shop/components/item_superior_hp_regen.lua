item_superior_hp_regen = class({})

LinkLuaModifier( "modifier_item_superior_hp_regen", "items/shop/components/item_superior_hp_regen.lua", LUA_MODIFIER_MOTION_NONE )

function item_superior_hp_regen:GetIntrinsicModifierName()
    return "modifier_item_superior_hp_regen"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_superior_hp_regen = modifier_item_superior_hp_regen or class({})

function modifier_item_superior_hp_regen:IsHidden() return true end
function modifier_item_superior_hp_regen:IsDebuff() return false end
function modifier_item_superior_hp_regen:IsPurgable() return false end
function modifier_item_superior_hp_regen:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_superior_hp_regen:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_superior_hp_regen:DeclareFunctions()
    return {    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_item_superior_hp_regen:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_hp_regen = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
    self:SetStackCount( 1 )
end

function modifier_item_superior_hp_regen:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen * self:GetStackCount()
end