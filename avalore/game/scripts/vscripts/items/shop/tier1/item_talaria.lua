item_talaria = class({})

LinkLuaModifier( "modifier_fairy_dust_buff", "items/shop/base_materials/item_fairy_dust.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_talaria", "items/shop/tier1/modifier_item_talaria.lua", LUA_MODIFIER_MOTION_NONE )

function item_talaria:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function item_talaria:GetIntrinsicModifierName()
    return "modifier_item_talaria"
end

function item_talaria:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_fairy_dust_buff", {duration = self:GetSpecialValueFor("flying_time")})
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_talaria = class({})

function modifier_item_talaria:IsHidden() return true end
function modifier_item_talaria:IsDebuff() return false end
function modifier_item_talaria:IsPurgable() return false end
function modifier_item_talaria:RemoveOnDeath() return false end
function modifier_item_talaria:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_talaria:DeclareFunctions()
    return {    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_talaria:OnCreated()
    self.item_ability = self:GetAbility()
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_mana_regen = self.item_ability:GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_talaria:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_leather_boots:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end
