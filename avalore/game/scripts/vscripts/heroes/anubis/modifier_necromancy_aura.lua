modifier_necromancy_aura = class({})

LinkLuaModifier( "modifier_talent_osiris_will", "scripts/vscripts/heroes/anubis/modifier_talent_osiris_will", LUA_MODIFIER_MOTION_NONE )

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
	if self.caster:HasTalent("talent_osiris_will") then
		print("GLOBAL")
		return 999999
	end
	print(tostring(self.radius))
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

function modifier_necromancy_aura:GetAuraEntityReject(target)
	if target:HasModifier("modifier_necromancy_aura_buff_form") then
		return true
	end
	return false
end
