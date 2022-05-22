modifier_calmecac_patronage_aura = class({})

LinkLuaModifier( "modifier_calmecac_patronage_aura_effect", "scripts/vscripts/heroes/quetzalcoatl/modifier_calmecac_patronage_aura_effect", LUA_MODIFIER_MOTION_NONE )

function modifier_calmecac_patronage_aura:IsHidden() return true end -- hide the emitter
function modifier_calmecac_patronage_aura:IsDebuff() return false end
function modifier_calmecac_patronage_aura:IsPurgable() return false end

function modifier_calmecac_patronage_aura:IsAura()
	if self:GetCaster():PassivesDisabled() then
		return false
	end

	if self:GetCaster():IsIllusion() then
		return false
	end

	return true
end

function modifier_calmecac_patronage_aura:GetModifierAura()
	return "modifier_calmecac_patronage_aura_effect"
end

function modifier_calmecac_patronage_aura:GetAuraRadius()
	return 25000
	--return FIND_UNITS_EVERYWHERE
end

function modifier_calmecac_patronage_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_calmecac_patronage_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end

function modifier_calmecac_patronage_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
	--return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP --use creeps for testing
end