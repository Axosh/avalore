item_essence_of_regeneration = class({})

LinkLuaModifier( "modifier_item_essence_of_regeneration", "items/shop/base_materials/item_essence_of_regeneration.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_regeneration_amplification", "items/shop/base_materials/item_essence_of_regeneration.lua", LUA_MODIFIER_MOTION_NONE )

function item_essence_of_regeneration:GetIntrinsicModifierName()
    return "modifier_item_essence_of_regeneration"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_essence_of_regeneration = modifier_item_essence_of_regeneration or class({})

function modifier_item_essence_of_regeneration:IsHidden()      return true  end
function modifier_item_essence_of_regeneration:IsDebuff()      return false end
function modifier_item_essence_of_regeneration:IsPurgable()    return false end
function modifier_item_essence_of_regeneration:RemoveOnDeath() return false end

function modifier_item_essence_of_regeneration:DeclareFunctions()
    return {  MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_item_essence_of_regeneration:OnCreated(kv)
    self.item_ability       = self:GetAbility()
    self.bonus_hp_regen   = self.item_ability:GetSpecialValueFor("passive_hp_regen")
end

function modifier_item_essence_of_regeneration:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end
