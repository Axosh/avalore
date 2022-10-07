modifier_avalore_ghost = modifier_avalore_ghost or class({})

function modifier_avalore_ghost:IsHidden() return false end
function modifier_avalore_ghost:IsPurgable() return true end
function modifier_avalore_ghost:IsDebuff() return false end

function modifier_avalore_ghost:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_avalore_ghost:OnCreated()
    -- need some values from the ability, so if we get here and don't have that, we should get out
    if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

    self.caster         = self:GetCaster()
	self.ability        = self:GetAbility()
	self.particle_boost = "particles/item/boots/haste_boots_speed_boost.vpcf"

    self.phase_ms                       = self.ability:GetSpecialValueFor("phase_ms")
    self.extra_spell_damage_percent		= self.ability:GetSpecialValueFor("extra_spell_damage_percent")

    if IsServer() then
		-- Apply particle effects
		local particle_boost_fx = ParticleManager:CreateParticle(self.particle_boost, PATTACH_ABSORIGIN_FOLLOW, self.caster)
		ParticleManager:SetParticleControl(particle_boost_fx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_boost_fx, 1, self.caster:GetAbsOrigin())
		self:AddParticle(particle_boost_fx, false, false, -1, false, false)
    end
end

function modifier_avalore_ghost:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end


function modifier_avalore_ghost:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,}
end

function modifier_avalore_ghost:GetModifierMoveSpeedBonus_Percentage()
	return self.phase_ms
end

function modifier_imba_ghost_state:GetModifierMagicalResistanceDecrepifyUnique()
    return self.extra_spell_damage_percent
end

function modifier_imba_ghost_state:OnAttackLanded(kv)
    self:Destroy()
end