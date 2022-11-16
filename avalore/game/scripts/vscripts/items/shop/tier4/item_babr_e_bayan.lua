item_babr_e_bayan = class({})

LinkLuaModifier( "modifier_item_babr_e_bayan", "items/shop/tier4/item_babr_e_bayan.lua", LUA_MODIFIER_MOTION_NONE )

function item_babr_e_bayan:GetIntrinsicModifierName()
    return "modifier_item_babr_e_bayan"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_babr_e_bayan = class({})

function modifier_item_babr_e_bayan:IsHidden() return true end
function modifier_item_babr_e_bayan:IsDebuff() return false end
function modifier_item_babr_e_bayan:IsPurgable() return false end
function modifier_item_babr_e_bayan:RemoveOnDeath() return false end
function modifier_item_babr_e_bayan:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_babr_e_bayan:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_babr_e_bayan:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.fire_resist = self.item_ability:GetSpecialValueFor("fire_resist")
    self.water_resist = self.item_ability:GetSpecialValueFor("water_resist")
end

function modifier_item_babr_e_bayan:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_babr_e_bayan:GetFireResist()
    return self.fire_resist
end

function modifier_item_babr_e_bayan:GetWaterResist()
    return self.water_resist
end