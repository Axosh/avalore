modifier_dust_devil = class({})

LinkLuaModifier("modifier_dust_devil_debuff", "heroes/pecos_bill/modifier_dust_devil_debuff.lua",        LUA_MODIFIER_MOTION_NONE )

function modifier_dust_devil:GetTexture()
    return "pecos_bill/dust_devil"
end

function modifier_dust_devil:IsHidden()   return false end
function modifier_dust_devil:IsPurgeabl() return false end
function modifier_dust_devil:IsDebuff()   return false end
function modifier_dust_devil:IsAura()     return true  end

function modifier_dust_devil:OnCreated()
    self.radius = self:GetCaster():FindTalentValue("talent_dust_devil", "slow_radius")
    self.caster = self:GetCaster()

    self.particle_sandstorm = "particles/hero/sand_king/sandking_sandstorm_aura.vpcf"
    self.particle_sandstorm_fx = ParticleManager:CreateParticle(self.particle_sandstorm, PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 0, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.particle_sandstorm_fx, 1, Vector(self.radius, self.radius, 1))
end

function modifier_dust_devil:GetAuraRadius()
	return self.radius
end

function modifier_dust_devil:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_dust_devil:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_dust_devil:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_dust_devil:GetModifierAura()
	return "modifier_dust_devil_debuff"
end

-- function modifier_dust_devil:GetEffectName()
-- 	return "particles/hero/sand_king/sandking_sandstorm_aura.vpcf"
-- end
