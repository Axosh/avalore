modifier_noxious_fog_aura = class({})

LinkLuaModifier( "modifier_noxious_fog_debuff", "heroes/davy_jones/modifier_noxious_fog_debuff.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_noxious_fog_aura:IsPurgable() return false end
function modifier_noxious_fog_aura:IsAura() return true end
function modifier_noxious_fog_aura:IsHidden() return true end

function modifier_noxious_fog_aura:OnCreated(kv)
	self.radius = kv.radius
    self.caster = self:GetCaster()
    if not IsServer() then return end
    self.fx1 = ParticleManager:CreateParticle("particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.fx1, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.fx1, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(self.fx1, 3, self.caster:GetAbsOrigin())
    self:AddParticle(self.fx1, false, false, -1, false, false)
    self.fx2 = ParticleManager:CreateParticle("particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin_beam_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.fx2, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.fx2, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(self.fx2, 3, self.caster:GetAbsOrigin())
    self:AddParticle(self.fx2, false, false, -1, false, false)
    self.fx3 = ParticleManager:CreateParticle("particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin_beam_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(self.fx3, 1, self.caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.fx3, 2, Vector(self.radius, self.radius, self.radius))
    ParticleManager:SetParticleControl(self.fx3, 3, self.caster:GetAbsOrigin())
    self:AddParticle(self.fx3, false, false, -1, false, false)
end

function modifier_noxious_fog_aura:OnRefresh()
	if IsServer() then return end
    self:OnCreated()
end

function modifier_noxious_fog_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_noxious_fog_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS
end

function modifier_noxious_fog_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_noxious_fog_aura:GetModifierAura()
	return "modifier_noxious_fog_debuff"
end

-- function modifier_noxious_fog_aura:GetEffectName()
--     --return "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7_puddle_bubble.vpcf" -- can't see it
-- 	--return "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf" -- doesn't work
--     return "particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin.vpcf"
-- end

-- function modifier_noxious_fog_aura:GetEffectAttachType()
--     return PATTACH_POINT_FOLLOW
-- 	--return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_noxious_fog_aura:GetAuraEntityReject(target)
	return false
end

function modifier_noxious_fog_aura:GetAuraRadius()
	return self.radius
end
