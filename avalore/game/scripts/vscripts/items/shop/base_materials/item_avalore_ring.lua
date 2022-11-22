item_avalore_ring = class({})

LinkLuaModifier( "modifier_item_avalore_ring", "items/shop/base_materials/item_avalore_ring.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_ring:GetIntrinsicModifierName()
    return "modifier_item_avalore_ring"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_avalore_ring = class({})

function modifier_item_avalore_ring:IsHidden() return true end
function modifier_item_avalore_ring:IsDebuff() return false end
function modifier_item_avalore_ring:IsPurgable() return false end
function modifier_item_avalore_ring:RemoveOnDeath() return false end
function modifier_item_avalore_ring:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_avalore_ring:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS      }
end

function modifier_item_avalore_ring:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_avalore_ring:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end