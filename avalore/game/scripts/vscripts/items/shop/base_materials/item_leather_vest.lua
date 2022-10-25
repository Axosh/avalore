item_leather_vest = class({})

LinkLuaModifier( "modifier_item_leather_vest", "items/shop/base_materials/item_leather_vest.lua", LUA_MODIFIER_MOTION_NONE )

function item_leather_vest:GetIntrinsicModifierName()
    return "modifier_item_leather_vest"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_leather_vest = class({})

function modifier_item_leather_vest:IsHidden() return true end
function modifier_item_leather_vest:IsDebuff() return false end
function modifier_item_leather_vest:IsPurgable() return false end
function modifier_item_leather_vest:RemoveOnDeath() return false end
function modifier_item_leather_vest:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_leather_vest:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_leather_vest:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_leather_vest:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end