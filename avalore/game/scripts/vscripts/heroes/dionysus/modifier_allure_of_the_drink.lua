modifier_allure_of_the_drink = modifier_allure_of_the_drink or class({})


function modifier_allure_of_the_drink:GetStatusEffectName()
	return "particles/status_fx/status_effect_lich_gaze.vpcf"
end

function modifier_allure_of_the_drink:OnCreated()
	self.ability 			= self:GetAbility()
	self.caster				= self:GetCaster()
	self.parent				= self:GetParent()

	self.destination		= self.ability:GetSpecialValueFor("destination") --+ self.caster:FindTalentValue("special_bonus_imba_lich_10")
	self.distance 			= CalcDistanceBetweenEntityOBB(self:GetCaster(), self:GetParent()) * (self.destination / 100)
	--self.mana_drain			= self.ability:GetSpecialValueFor("mana_drain")

	if not IsServer() then return end

	self.status_resistance = self:GetParent():GetStatusResistance()

	self.duration			= self:GetRemainingTime()
	self.interval			= 0.1

	-- if self.parent.GetMana then
	-- 	self.current_mana		= self.parent:GetMana()
	-- else
	-- 	self.current_mana		= 0
	-- end

	--self.mana_per_interval	= (self.current_mana * self.mana_drain * 0.01) / (self.duration / self.interval)

	-- This is so errors don't pop up if the spell gets reflected
	if self.caster:GetName() == "npc_dota_hero_brewmaster" then
		-- Particle attachments aren't perfect but they're good enough...I guess
		-- Add the gaze particles
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_gaze.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_portrait", self.caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle, 3, self.caster, PATTACH_ABSORIGIN_FOLLOW, nil, self.caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle, 10, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
		self:AddParticle(self.particle, false, false, -1, false, false)

		-- Add the red eyes particle
		self.particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_gaze_eyes.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle2, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_eye_l", self.caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle2, 2, self.caster, PATTACH_POINT_FOLLOW, "attach_eye_r", self.caster:GetAbsOrigin(), true)
		self:AddParticle(self.particle2, false, false, -1, false, false)
	end

	self.parent:Interrupt()
	self.parent:MoveToNPC(self.caster)

	self:StartIntervalThink(self.interval)
end

function modifier_allure_of_the_drink:OnIntervalThink()
	if not self:GetCaster() or not self:GetAbility() or not self:GetAbility():IsChanneling() then
		self:Destroy()
    end
end

function modifier_allure_of_the_drink:OnDestroy()
	if not IsServer() then return end

	self.parent:Interrupt()
	
	-- Why 100? IDK random number
	GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), 100, false)

	if self.ability:IsChanneling() and not self:GetCaster():HasScepter() then
		self.ability:EndChannel(false)
		self.caster:MoveToPositionAggressive(self.caster:GetAbsOrigin())
	end
end

function modifier_allure_of_the_drink:CheckState()
	return {
		[MODIFIER_STATE_HEXED] = true,	-- Using this as substitute for Fear which isn't a provided state
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
end

function modifier_allure_of_the_drink:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_LIMIT}
end

function modifier_allure_of_the_drink:GetModifierMoveSpeed_Limit()
	if not IsServer() then return end
	
	if not self:GetCaster():HasScepter() then
		return self.distance / (self.ability:GetChannelTime() * (1 - math.min(self.status_resistance, 0.9999))) -- If target has 100% status resistance, make non-divide by 0 so target zips to caster
	else
		return self.distance / self.ability:GetChannelTime()
	end
end

