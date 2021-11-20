modifier_tyrant_king_aura = class({})

LinkLuaModifier("modifier_tyrant_king_debuff",    "scripts/vscripts/heroes/gilgamesh/modifier_tyrant_king_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_tyrant_king_aura:IsPurgable()	return false end
function modifier_tyrant_king_aura:IsAura() return true end

function modifier_tyrant_king_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_tyrant_king_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_tyrant_king_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO --+ DOTA_UNIT_TARGET_OTHER 
end

function modifier_tyrant_king_aura:GetModifierAura()
    return "modifier_tyrant_king_debuff"
end

function modifier_tyrant_king_aura:OnCreated()
    self.radius			= self:GetAbility():GetSpecialValueFor("radius")
    self.tick_interval	= 0.1

    if not IsServer() then return end

    -- local aura_particle = ParticleManager:CreateParticle("particles/econ/events/spring_2021/bottle_spring_2021_ring_green.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	-- ParticleManager:SetParticleControl(aura_particle, 5, Vector(self.radius * 1.1, 0, 0))
	-- self:AddParticle(aura_particle, false, false, -1, false, false)

    -- local spotlight_particle = ParticleManager:CreateParticle("particles/econ/events/spring_2021/teleport_end_spring_2021_lvl2.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	-- ParticleManager:SetParticleControl(spotlight_particle, 5, Vector(0, 0, 0))
	-- self:AddParticle(spotlight_particle, false, false, -1, false, false)

    self:StartIntervalThink(self.tick_interval)
end

function modifier_tyrant_king_aura:GetAuraRadius()
    return self.radius
end

function modifier_tyrant_king_aura:OnIntervalThink()
    local radius = self:GetAuraRadius()
    local units = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    for _,unit in pairs(units) do
        local filter = unit:FindModifierByName( 'modifier_tyrant_king_debuff' )
		if filter then
            --unit:
        end
    end
end