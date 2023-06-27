item_helm = class({})

LinkLuaModifier( "modifier_item_helm", "items/shop/base_materials/item_helm.lua", LUA_MODIFIER_MOTION_NONE )

function item_helm:GetIntrinsicModifierName()
    return "modifier_item_helm"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_helm = class({})

function modifier_item_helm:IsHidden() return true end
function modifier_item_helm:IsDebuff() return false end
function modifier_item_helm:IsPurgable() return false end
function modifier_item_helm:RemoveOnDeath() return false end
function modifier_item_helm:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_helm:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS      }
end

function modifier_item_helm:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_as = self.item_ability:GetSpecialValueFor("bonus_as")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
end

function modifier_item_helm:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_helm:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end

function modifier_item_helm:GetModifierBonusStats_Intellect()
    return self.bonus_int
end