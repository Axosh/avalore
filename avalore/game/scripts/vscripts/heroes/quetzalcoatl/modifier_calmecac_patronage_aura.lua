modifier_calmecac_patronage_aura = class({})

function modifier_calmecac_patronage_aura:IsHidden() return false end
function modifier_calmecac_patronage_aura:IsDebuff() return false end
function modifier_calmecac_patronage_aura:IsPurgable() return false end

function modifier_calmecac_patronage_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function modifier_calmecac_patronage_aura:GetModifierAura()
	return "modifier_calmecac_patronage_aura_effect"
end

function modifier_calmecac_patronage_aura:GetAuraRadius()
	return FIND_UNITS_EVERYWHERE
end

function modifier_calmecac_patronage_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_calmecac_patronage_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end