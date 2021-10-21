item_steel = class({})

LinkLuaModifier( "modifier_item_steel", "items/shop/components/item_steel.lua", LUA_MODIFIER_MOTION_NONE )

function item_steel:GetIntrinsicModifierName()
    return "modifier_item_steel"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_steel = class({})

function modifier_item_steel:IsHidden() return true end
function modifier_item_steel:IsDebuff() return false end
function modifier_item_steel:IsPurgable() return false end
function modifier_item_steel:RemoveOnDeath() return false end
function modifier_item_steel:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_steel:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_steel:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_steel:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end