require("constants")
modifier_flag_agility = class({})

function modifier_flag_agility:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_flag_agility:IsHidden() return false end
function modifier_flag_agility:IsDebuff() return false end
function modifier_flag_agility:IsPurgable() return false end

function modifier_flag_agility:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
end

function modifier_flag_agility:GetTexture()
    return "invoker_alacrity"
end

function modifier_flag_agility:DeclareFunctions()
    local functs = {
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        DOTA_ABILITY_BEHAVIOR_AURA,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return functs
end

function modifier_flag_agility:GetModifierMoveSpeedBonus_Percentage_Unique()
    return 15
end

function modifier_flag_agility:GetModifierAttackSpeedBonus_Constant()
    return 15
end