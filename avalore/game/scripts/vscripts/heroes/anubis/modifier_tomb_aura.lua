modifier_tomb_aura = modifier_tomb_aura or class({})

LinkLuaModifier("modifier_tomb_aura_buff",    "scripts/vscripts/heroes/anubis/modifier_tomb_aura_buff.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_tomb_aura:IsHidden() return false end
function modifier_tomb_aura:IsPurgable() return false end 
function modifier_tomb_aura:IsDebuff() return false end
function modifier_tomb_aura:IsAura() return true end

function modifier_tomb_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_tomb_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_tomb_aura:GetModifierAura()
    return "modifier_tomb_aura_buff"
end

function modifier_tomb_aura:GetAuraRadius()
    return self.radius
end

function modifier_tomb_aura:OnCreated()
    self.radius			= self:GetAbility():GetSpecialValueFor("radius")

    if not IsServer() then return end
    local aura_particle = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ring_spiral.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	--ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
    ParticleManager:SetParticleControl(aura_particle, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z+64))
	ParticleManager:SetParticleControl(aura_particle, 10, Vector(self.radius, self.radius, 0))
	self:AddParticle(aura_particle, false, false, -1, false, false)
end