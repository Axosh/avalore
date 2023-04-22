item_staff_of_sorcery = class({})

LinkLuaModifier( "modifier_item_staff_of_sorcery", "items/shop/tier1/item_staff_of_sorcery.lua", LUA_MODIFIER_MOTION_NONE )

function item_staff_of_sorcery:GetIntrinsicModifierName()
    return "modifier_item_staff_of_sorcery"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_staff_of_sorcery = modifier_item_staff_of_sorcery or class({})

function modifier_item_staff_of_sorcery:IsHidden() return true end
function modifier_item_staff_of_sorcery:IsDebuff() return false end
function modifier_item_staff_of_sorcery:IsPurgable() return false end
function modifier_item_staff_of_sorcery:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_staff_of_sorcery:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_staff_of_sorcery:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_staff_of_sorcery:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self:SetStackCount( 1 )
end

function modifier_item_staff_of_sorcery:GetModifierBonusStats_Intellect()
    return self.bonus_int * self:GetStackCount()
end

function modifier_item_staff_of_sorcery:GetModifierConstantManaRegen()
    return self.bonus_mana_regen * self:GetStackCount()
end