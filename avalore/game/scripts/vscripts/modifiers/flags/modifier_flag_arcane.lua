require("constants")
modifier_flag_arcane = class({})

function modifier_flag_arcane:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_flag_arcane:IsHidden() return false end
function modifier_flag_arcane:IsDebuff() return false end
function modifier_flag_arcane:IsPurgable() return false end
function modifier_flag_arcane:RemoveOnDeath() return false end

function modifier_flag_arcane:OnCreated()
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
end

function modifier_flag_arcane:GetTexture()
    return "skywrath_mage_ancient_seal"
end

function modifier_flag_arcane:DeclareFunctions()
    local functs = {
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_ABILITY_BEHAVIOR_PASSIVE,
        DOTA_ABILITY_BEHAVIOR_AURA,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT
    }
    return functs
end

function modifier_flag_arcane:GetModifierSpellAmplify_Percentage()
    return 5
end

function modifier_flag_arcane:GetModifierCooldownReduction_Constant()
    return 5
end