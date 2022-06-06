modifier_tyrant_king_aura = class({})

LinkLuaModifier("modifier_tyrant_king_debuff",    "scripts/vscripts/heroes/gilgamesh/modifier_tyrant_king_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_tyrant_king_aura:IsPurgable()	return false end
function modifier_tyrant_king_aura:IsAura() return true end
function modifier_tyrant_king_aura:IsDebuff() return false end

function modifier_tyrant_king_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_tyrant_king_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_tyrant_king_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO --+ DOTA_UNIT_TARGET_OTHER 
end

function modifier_tyrant_king_aura:GetAuraEntityReject(hEntity)
    if IsServer() then
		if self:GetParent() == hEntity then
			return true
		end
	end

	return false
end

function modifier_tyrant_king_aura:GetModifierAura()
    return "modifier_tyrant_king_debuff"
end

function modifier_tyrant_king_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_EVENT_ON_KILL
    }
end

function modifier_tyrant_king_aura:OnCreated()
    self.radius			= self:GetAbility():GetSpecialValueFor("radius")
    self.leech_percent  = self:GetAbility():GetSpecialValueFor("leech_percent")
    self.tick_interval	= 0.1
    self.borrowed_dmg   = 0 -- init (going to be set by thinker)

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
    --if not IsServer() then return end

    local radius = self:GetAuraRadius()
    local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    self.borrowed_dmg = 0

    for _,unit in pairs(units) do
        local filter = unit:FindModifierByName( 'modifier_tyrant_king_debuff' )
		if unit ~= self:GetCaster() and filter then
            self.borrowed_dmg = self.borrowed_dmg + (unit:GetAttackDamage() * self.leech_percent)
        end
    end

    print("Borrowed Damage: " .. tostring(self.borrowed_dmg))
end

function modifier_tyrant_king_aura:GetModifierBaseAttack_BonusDamage()
    return self.borrowed_dmg
end

-- function modifier_tyrant_king_aura:OnKill()

-- end