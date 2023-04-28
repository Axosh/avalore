item_circes_staff = class({})

LinkLuaModifier( "modifier_item_circes_staff", "items/shop/tier1/item_circes_staff.lua", LUA_MODIFIER_MOTION_NONE )

function item_circes_staff:GetIntrinsicModifierName()
    return "modifier_item_circes_staff"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_circes_staff = modifier_item_circes_staff or class({})

function modifier_item_circes_staff:IsHidden() return true end
function modifier_item_circes_staff:IsDebuff() return false end
function modifier_item_circes_staff:IsPurgable() return false end
function modifier_item_circes_staff:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_circes_staff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_circes_staff:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_circes_staff:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
    self:SetStackCount( 1 )
end

function modifier_item_circes_staff:GetModifierBonusStats_Intellect()
    return self.bonus_int * self:GetStackCount()
end

function modifier_item_circes_staff:GetModifierConstantManaRegen()
    return self.bonus_mana_regen * self:GetStackCount()
end