modifier_blinding_fog_aura = class({})

LinkLuaModifier( "modifier_blind_debuff", "modifiers/modifier_blind_debuff.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_blinding_fog_aura:IsPurgable() return false end
function modifier_blinding_fog_aura:IsAura() return true end

function modifier_blinding_fog_aura:GetAuraSearchTeam()
    return DTOA_UNTI_TARGET_TEAM_ENEMY
end

function modifier_blinding_fog_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE 
end

function modifier_blinding_fog_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_OTHER 
end

function modifier_blinding_fog_aura:GetModifierAura()
    return "modifier_blind_debuff"
end

function modifier_blinding_fog_aura:GetAuraRadius()
    return self.radius
end

function modifier_blinding_fog_aura:OnCreated(kv)
    self.radius = kv.radius
    self.caster = self:GetCaster()
    if not IsServer() then return end
    print("rad = " .. tostring(self.radius))

    --local aura_particle = ParticleManager:CreateParticle("particles/hero/sand_king/sandking_sandstorm_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    local aura_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    --ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
    -- ParticleManager:SetParticleControl(aura_particle, 0, self:GetParent():GetAbsOrigin())
    -- ParticleManager:SetParticleControl(aura_particle, 1, Vector(self.radius, self.radius, 1))

    ParticleManager:SetParticleControl(aura_particle, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(aura_particle, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(aura_particle, 3, self.caster:GetAbsOrigin())

    -- color (gray)
    --ParticleManager:SetParticleControl(aura_particle, 3, Vector(200, 200, 200))
    
    self:AddParticle(aura_particle, false, false, -1, false, false)
end