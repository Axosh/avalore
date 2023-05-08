item_magic_armor = class({})

LinkLuaModifier( "modifier_item_magic_armor", "items/shop/components/item_magic_armor.lua", LUA_MODIFIER_MOTION_NONE )

function item_magic_armor:GetIntrinsicModifierName()
    return "modifier_item_magic_armor"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_magic_armor = modifier_item_magic_armor or class({})

function modifier_item_magic_armor:IsHidden() return true end
function modifier_item_magic_armor:IsDebuff() return false end
function modifier_item_magic_armor:IsPurgable() return false end
function modifier_item_magic_armor:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_magic_armor:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_magic_armor:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_item_magic_armor:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.magic_resist = self.item_ability:GetSpecialValueFor("magic_resist")
    self:SetStackCount( 1 )
end

function modifier_item_magic_armor:GetModifierMagicalResistanceBonus()
    return self.magic_resist * self:GetStackCount()
end