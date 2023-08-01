item_frost_fair_blade = class({})

LinkLuaModifier( "modifier_item_frost_fair_blade", "items/shop/tier5/item_frost_fair_blade.lua", LUA_MODIFIER_MOTION_NONE )

function item_frost_fair_blade:GetIntrinsicModifierName()
    return "modifier_item_frost_fair_blade"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_frost_fair_blade = modifier_item_frost_fair_blade or class({})

function modifier_item_frost_fair_blade:IsHidden() return true end
function modifier_item_frost_fair_blade:IsDebuff() return false end
function modifier_item_frost_fair_blade:IsPurgable() return false end
function modifier_item_frost_fair_blade:RemoveOnDeath() return false end

function modifier_item_frost_fair_blade:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_item_frost_fair_blade:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_item_frost_fair_blade:GetModifierBonusStats_Strength()
    return self.bonus_str + (self:GetParent():GetBaseStrength() * (self.bonus_str_mult - 1))
end

function modifier_item_frost_fair_blade:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_frost_fair_blade:GetModifierMoveSpeedBonus_Percentage()
    return (-1 * self.ms_slow)
end

function modifier_item_frost_fair_blade:GetModifierAttackSpeedBonus_Constant()
    return (-1 * self.as_slow)
end

function modifier_item_frost_fair_blade:OnRemove()
    if not IsServer() then return end
    ParticleManager:DestroyParticle(self.slow_hit_particle, false);
end