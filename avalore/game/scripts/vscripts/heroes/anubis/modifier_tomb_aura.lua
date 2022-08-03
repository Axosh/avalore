modifier_tomb_aura = modifier_tomb_aura or class({})

LinkLuaModifier("modifier_tomb_aura_buff",    "scripts/vscripts/heroes/anubis/modifier_tomb_aura_buff.lua", LUA_MODIFIER_MOTION_NONE)
-- TALENTS
LinkLuaModifier("modifier_talent_great_pyramid",    		  "scripts/vscripts/heroes/anubis/modifier_talent_great_pyramid.lua", LUA_MODIFIER_MOTION_NONE)

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
    return self.radius + self:GetAbility():GetCaster():FindTalentValue("talent_great_pyramid", "bonus_radius")
end

function modifier_tomb_aura:OnCreated()
    -- if the hero has the talent, then it also gets added to the pyramid so the value is available
    --print("Caster => " .. self:GetAbility():GetCaster():GetName())
    self.radius			= self:GetAbility():GetSpecialValueFor("radius") --+ self:GetAbility():GetCaster():FindTalentValue("talent_great_pyramid", "bonus_radius")
    -- if self:GetAbility():GetCaster():HasModifier("modifier_talent_great_pyramid") then
    --     print("has talent")
    --     self.radius = self.radius + 
    -- end
    --self.radius = self:GetAbility():GetCastRange()
    --print(self:GetAbility():GetName())
    --print("Radius => " .. tostring(self.radius))

    if not IsServer() then return end
    local aura_particle = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_ring_spiral.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(aura_particle, 0, Vector(self:GetParent():GetAbsOrigin().x,self:GetParent():GetAbsOrigin().y,self:GetParent():GetAbsOrigin().z+64))
	ParticleManager:SetParticleControl(aura_particle, 10, Vector(self.radius, self.radius, 0))
    self:AddParticle(aura_particle, false, false, -1, false, false)

    aura_particle = ParticleManager:CreateParticle("particles/hero/sand_king/sandking_sandstorm_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	--ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
    ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))
    
	self:AddParticle(aura_particle, false, false, -1, false, false)
end

--function modifier_tomb_aura: