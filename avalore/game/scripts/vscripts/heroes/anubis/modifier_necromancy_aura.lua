modifier_necromancy_aura = class({})

function modifier_necromancy_aura:AllowIllusionDuplicate() return false end
function modifier_necromancy_aura:IsHidden() return true end
function modifier_necromancy_aura:IsPurgable() return false end
function modifier_necromancy_aura:IsDebuff() return false end
function modifier_necromancy_aura:IsAura() return true end

function modifier_necromancy_aura:OnCreated()
    self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- Ability specials
	self.radius = self.ability:GetSpecialValueFor("radius")
end

function modifier_necromancy_aura:GetAuraRadius()
	return self.radius
end

function modifier_necromancy_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_necromancy_aura:GetAuraSearchType()
		return DOTA_UNIT_TARGET_HERO
end

function modifier_necromancy_aura:GetModifierAura()
	return "modifier_necromancy_aura_buff"
end

