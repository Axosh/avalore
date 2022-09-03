item_pauldrons = class({})

LinkLuaModifier( "modifier_item_pauldrons", "items/shop/base_materials/item_pauldrons.lua", LUA_MODIFIER_MOTION_NONE )

function item_pauldrons:GetIntrinsicModifierName()
    return "modifier_item_pauldrons"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_pauldrons = class({})

function modifier_item_pauldrons:IsHidden() return true end
function modifier_item_pauldrons:IsDebuff() return false end
function modifier_item_pauldrons:IsPurgable() return false end
function modifier_item_pauldrons:RemoveOnDeath() return false end
function modifier_item_pauldrons:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_pauldrons:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_pauldrons:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_pauldrons:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end