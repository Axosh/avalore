item_avalore_gauntlets = class({})

LinkLuaModifier( "modifier_item_avalore_gauntlets", "items/shop/base_materials/item_avalore_gauntlets.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_gauntlets:GetIntrinsicModifierName()
    return "modifier_item_avalore_gauntlets"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_avalore_gauntlets = modifier_item_avalore_gauntlets or class({})

function modifier_item_avalore_gauntlets:IsHidden() return true end
function modifier_item_avalore_gauntlets:IsDebuff() return false end
function modifier_item_avalore_gauntlets:IsPurgable() return false end
function modifier_item_avalore_gauntlets:RemoveOnDeath() return false end
function modifier_item_avalore_gauntlets:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_avalore_gauntlets:DeclareFunctions()
    return {   MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_avalore_gauntlets:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_avalore_gauntlets:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end