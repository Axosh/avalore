modifier_grapple_target = class({})

function modifier_grapple_target:IsPurgable()			return false end
function modifier_grapple_target:IsPurgeException()	    return true end
function modifier_grapple_target:GetAttributes() 		return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_grapple_target:OnCreated()
    if not IsServer() then return end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)

    self.particle = self:AddParticle(particle, true, false, -1, true, false)

    self.tick_interval			= self:GetAbility():GetSpecialValueFor("tick_interval")
	self.total_damage			= self:GetAbility():GetSpecialValueFor("total_damage")
	self.channel_time			= self:GetAbility():GetSpecialValueFor("channel_time")

    self.damage_per_tick	= self.total_damage / (self.channel_time / self.tick_interval)

    self:StartIntervalThink(self.tick_interval)
end

function modifier_grapple_target:OnIntervalThink()
    if not IsServer() then return end

    if not self:GetAbility():IsChanneling() then
		self:Destroy()
	else
		local damageTable = {
			victim 			= self:GetParent(),
			damage 			= self.damage_per_tick,
			damage_type		= self:GetAbility():GetAbilityDamageType(),
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self:GetAbility()
		}

		ApplyDamage(damageTable)
    end
end

function modifier_grapple_target:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_grapple_target:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_grapple_target:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end