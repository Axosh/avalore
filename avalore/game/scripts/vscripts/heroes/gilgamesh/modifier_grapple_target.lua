modifier_grapple_target = class({})

LinkLuaModifier( "modifier_talent_tag_team", "scripts/vscripts/heroes/gilgamesh/modifier_talent_tag_team.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_grapple_target:IsPurgable()			return false end
function modifier_grapple_target:IsPurgeException()	    return true end
function modifier_grapple_target:GetAttributes() 		return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_grapple_target:OnCreated(kv)
    if not IsServer() then return end

	-- find the main hero (e.g. gilgamesh) for the talent since enkidu might be casting
	local main_hero = PlayerResource:GetSelectedHeroEntity(self:GetCaster():GetMainControllingPlayer())
	self.amplify_damage = main_hero:FindTalentValue("talent_tag_team","bonus_dmg_pct")
	print("damage amp? " .. tostring(self.amplify_damage))

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)

    self.particle = self:AddParticle(particle, true, false, -1, true, false)

    self.tick_interval			= self:GetAbility():GetSpecialValueFor("tick_interval")
	self.total_damage			= self:GetAbility():GetSpecialValueFor("total_damage")
	--self.channel_time			= self:GetAbility():GetSpecialValueFor("channel_time")
	self.channel_time 			= kv.duration
	--self.channel_time			= self:GetAbility():GetSpecialValueFor("channel_time") + self:GetCaster():FindTalentValue("talent_endurance", "bonus_duration")
	print("Channel Time => " .. tostring(self.channel_time))

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
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_grapple_target:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_grapple_target:GetModifierIncomingDamage_Percentage(kv)
	-- check that they have the talent
	if self.amplify_damage > 0 then
		-- if the source of the damage is the player grappling this target
		if kv.attacker:GetMainControllingPlayer() == self:GetCaster():GetMainControllingPlayer() then
			--print("amping damage!!!!")
			return self.amplify_damage
		end
	end
end