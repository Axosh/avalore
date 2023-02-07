ability_avalore_attributes = ability_avalore_attributes or class({})

LinkLuaModifier("modifier_avalore_attributes",   "scripts/vscripts/heroes/_shared/ability_avalore_attributes.lua", LUA_MODIFIER_MOTION_NONE)

-- function ability_avalore_attributes:GetIntrinsicModifierName()
--     return "modifier_avalore_attributes"
-- end

function ability_avalore_attributes:OnUpgrade()
    --print("Attributes Leveled")
    --self:GetCaster():FindModifierByName("modifier_avalore_attributes"):ForceRefresh()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_avalore_attributes", {})
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_avalore_attributes = class({})

function modifier_avalore_attributes:IsHidden() return true end
function modifier_avalore_attributes:IsDebuff() return false end
function modifier_avalore_attributes:IsPurgable() return false end
function modifier_avalore_attributes:RemoveOnDeath() return false end
-- function modifier_avalore_attributes:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_avalore_attributes:DeclareFunctions()
    return {    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_avalore_attributes:OnCreated()
    --print("modifier_avalore_attributes:OnCreated()")
    self.raw_dmg        = self:GetAbility():GetSpecialValueFor("raw_dmg")
    self.raw_ms         = self:GetAbility():GetSpecialValueFor("raw_ms")
    self.minor_stats    = self:GetAbility():GetSpecialValueFor("minor_stats")
    self.attack_speed   = self:GetAbility():GetSpecialValueFor("attack_speed")
    self.mana_regen     = self:GetAbility():GetSpecialValueFor("mana_regen")
    self.major_stats    = self:GetAbility():GetSpecialValueFor("major_stats")

    self.bonus_dmg      = 0
    self.bonus_ms       = 0
    self.bonus_stats    = 0
    self.bonus_as       = 0
    self.bonus_regen    = 0

    self:OnRefresh()
end

function modifier_avalore_attributes:OnRefresh()
    local ability_level = self:GetAbility():GetLevel()
    --print("Refreshing Attributes - level " .. tostring(ability_level))

    if ability_level > 0 then
        self.bonus_dmg = self.raw_dmg
    end

    if ability_level > 1 then
        self.bonus_ms = self.raw_ms
    end

    if ability_level > 2 then
        self.bonus_stats = self.minor_stats
    end

    if ability_level > 3 then
        self.bonus_as = self.attack_speed
    end

    if ability_level > 4 then
        self.bonus_regen = self.mana_regen
    end

    if ability_level > 5 then
        self.bonus_stats = self.bonus_stats + self.major_stats
    end
end

function modifier_avalore_attributes:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_avalore_attributes:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_ms
end

function modifier_avalore_attributes:GetModifierConstantManaRegen()
    return self.bonus_regen
end

function modifier_avalore_attributes:GetModifierBonusStats_Strength()
    return self.bonus_stats
end

function modifier_avalore_attributes:GetModifierBonusStats_Agility()
    return self.bonus_stats
end

function modifier_avalore_attributes:GetModifierBonusStats_Intellect()
    return self.bonus_stats
end

function modifier_avalore_attributes:GetModifierAttackSpeedBonus_Constant()
    return self.bonus_as
end