modifier_maenadic_frenzy_aura = class({})

LinkLuaModifier("modifier_maenadic_frenzy_debuff", "heroes/dionysus/modifier_maenadic_frenzy_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_maenadic_frenzy_aura:IsPurgable()	return false end
function modifier_maenadic_frenzy_aura:IsAura() return true end

function modifier_maenadic_frenzy_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_maenadic_frenzy_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_maenadic_frenzy_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_OTHER 
end

function modifier_maenadic_frenzy_aura:GetModifierAura()
        return "modifier_maenadic_frenzy_debuff"
end

function modifier_maenadic_frenzy_aura:GetAuraRadius()
    return self.radius
end

function modifier_maenadic_frenzy_aura:OnCreated()
    self.radius			= self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("talent_ritual_madness", "bonus_aura_aoe")

    if not IsServer() then return end

    local aura_particle = ParticleManager:CreateParticle("particles/econ/events/spring_2021/bottle_spring_2021_ring_green.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
	self:AddParticle(aura_particle, false, false, -1, false, false)

    local spotlight_particle = ParticleManager:CreateParticle("particles/econ/events/spring_2021/teleport_end_spring_2021_lvl2.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(spotlight_particle, 5, Vector(0, 0, 0))
	self:AddParticle(spotlight_particle, false, false, -1, false, false)
end