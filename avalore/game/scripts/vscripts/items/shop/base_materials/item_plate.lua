item_plate = class({})

LinkLuaModifier( "modifier_item_plate", "items/shop/base_materials/item_plate.lua", LUA_MODIFIER_MOTION_NONE )

function item_plate:GetIntrinsicModifierName()
    return "modifier_item_plate"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_plate = class({})

function modifier_item_plate:IsHidden() return true end
function modifier_item_plate:IsDebuff() return false end
function modifier_item_plate:IsPurgable() return false end
function modifier_item_plate:RemoveOnDeath() return false end
function modifier_item_plate:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_plate:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK      }
end

function modifier_item_plate:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.damage_block = self.item_ability:GetSpecialValueFor("damage_block")
end

function modifier_item_plate:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_plate:GetModifierPhysical_ConstantBlock()
    return self.damage_block
end