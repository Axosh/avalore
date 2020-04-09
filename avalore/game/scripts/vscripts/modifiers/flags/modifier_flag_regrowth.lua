require("constants")
modifier_flag_regrowth = class({})

function modifier_flag_regrowth:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_flag_regrowth:IsHidden() return false end
function modifier_flag_regrowth:IsDebuff() return false end
function modifier_flag_regrowth:IsPurgable() return false end

function modifier_flag_regrowth:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
end

function modifier_flag_regrowth:GetTexture()
    return "treant_living_armor"
    --return "treant_natures_grasp"
end

function modifier_flag_regrowth:DeclareFunctions()
    local functs = {
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        DOTA_ABILITY_BEHAVIOR_AURA,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE
    }
    return functs
end

function modifier_flag_regrowth:GetModifierConstantHealthRegen()
    return 2
end

function modifier_flag_regrowth:GetModifierExtraHealthPercentage()
    return 5
end