item_crown = class({})

LinkLuaModifier( "modifier_item_crown", "items/shop/base_materials/item_crown.lua", LUA_MODIFIER_MOTION_NONE )

function item_crown:GetIntrinsicModifierName()
    return "modifier_item_crown"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_crown = class({})

function modifier_item_crown:IsHidden() return true end
function modifier_item_crown:IsDebuff() return false end
function modifier_item_crown:IsPurgable() return false end
function modifier_item_crown:RemoveOnDeath() return false end
function modifier_item_crown:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_crown:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_crown:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_crown:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end