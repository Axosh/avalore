modifier_gunslinger = class({})

LinkLuaModifier("modifier_disarming_shot_tracker", "heroes/pecos_bill/modifier_disarming_shot_tracker.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_avalore_disarm",     "modifiers/base_spell/modifier_avalore_disarm.lua", LUA_MODIFIER_MOTION_NONE)

function modifier_gunslinger:IsHidden() return false end
function modifier_gunslinger:IsDebuff() return false end
function modifier_gunslinger:IsStunDebuff() return false end
function modifier_gunslinger:IsPurgable() return true end

function modifier_gunslinger:OnCreated(kv)
    self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	--self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	self.records = {}

	-- play Effects & Sound
	--self:PlayEffects()
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:OnRefresh( kv )
	-- references
	self.attacks = self:GetAbility():GetSpecialValueFor( "buffed_attacks" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.as_bonus = self:GetAbility():GetSpecialValueFor( "attack_speed_bonus" )
	self.range_bonus = self:GetAbility():GetSpecialValueFor( "attack_range_bonus" )
	self.bat = self:GetAbility():GetSpecialValueFor( "base_attack_time" )

	--self.slow = self:GetAbility():GetSpecialValueFor( "slow_duration" )

	if not IsServer() then return end
	self:SetStackCount( self.attacks )

	-- play sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:OnRemoved()
end

function modifier_gunslinger:OnDestroy()
	if not IsServer() then return end

	-- stop sound
	local sound_cast = "Hero_Snapfire.ExplosiveShells.Cast"
	StopSoundOn( sound_cast, self:GetParent() )
end

function modifier_gunslinger:DeclareFunctions()
	local funcs = {
		 MODIFIER_EVENT_ON_ATTACK,
		 MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,

		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}

	return funcs
end

function modifier_gunslinger:OnAttack(kv)
	if not IsServer() then return end

	if kv.attacker~=self:GetParent() then return end
	if self:GetStackCount()<=1 then
		self:Destroy()
	end

	if self:GetStackCount()>1 then
		self:DecrementStackCount()
		if self:GetParent():HasTalent("talent_disarming_shot") then
			local debuff = kv.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_disarming_shot_tracker", {duration = self:GetParent():FindTalentValue("talent_disarming_shot", "linger_time")})
			print("Stack Count = " .. tostring(debuff:GetStackCount()))
			if debuff:GetStackCount() > (self:GetParent():FindTalentValue("talent_disarming_shot", "shots_to_disarm") - 1) then
				kv.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_avalore_disarm", {duration = self:GetParent():FindTalentValue("talent_disarming_shot", "disarm_time")})
			end
		end
	end
end

function modifier_gunslinger:OnAttackLanded(kv)
	if not IsServer() then return end
	if kv.attacker ~= self:GetParent() then return end

	if self:GetParent():HasTalent("talent_explosive_shells") then
		local target = kv.target
		if not self.explosion_radius then
			self.explosion_radius = self:GetParent():FindTalentValue("talent_explosive_shells", "radius")
		end
		-- if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		-- 	DoCleaveAttack( self:GetParent(), target, self:GetAbility(), kv.damage, self.explosion_radius, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
		-- end

		-- Emit particle
		--local particle	=	"particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_base_attack_explosion.vpcf"
		--local particle	=	"particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_fireblast_streak.vpcf"
		local particle = "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf" --works but is kinda distracting
		--local particle = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_explosion.vpcf"
		local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(particle_fx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_fx, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_fx, 2, Vector(self.explosion_radius, 1, 1))
		ParticleManager:ReleaseParticleIndex(particle_fx)

		-- Find enemies around the target
		local enemies	=	FindUnitsInRadius(	self:GetParent():GetTeamNumber(),
							target:GetAbsOrigin(),
							nil,
							self.explosion_radius,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
							DOTA_UNIT_TARGET_FLAG_NONE,
							FIND_ANY_ORDER,
							false)

		for _,enemy in pairs(enemies) do
			-- Deal damage
			local damageTable = {	victim = enemy,
									damage = kv.damage,
									damage_type = DAMAGE_TYPE_PHYSICAL, --DAMAGE_TYPE_MAGICAL,
									attacker = self:GetParent(),
									ability = self:GetAbility()
								}
			ApplyDamage(damageTable)
		end
	end

end

-- function modifier_gunslinger:GetModifierProjectileName()
-- 	if self:GetStackCount()<=0 then return end
-- 	return "particles/units/heroes/hero_snapfire/hero_snapfire_shells_projectile.vpcf"
-- end

function modifier_gunslinger:GetModifierOverrideAttackDamage()
	if self:GetStackCount()<=0 then return end
	return self.damage
end

function modifier_gunslinger:GetModifierAttackRangeBonus()
	if self:GetStackCount()<=0 then return end
	return self.range_bonus
end

function modifier_gunslinger:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount()<=0 then return end
	return self.as_bonus
end

function modifier_gunslinger:GetModifierBaseAttackTimeConstant()
	if self:GetStackCount()<=0 then return end
	return self.bat
end