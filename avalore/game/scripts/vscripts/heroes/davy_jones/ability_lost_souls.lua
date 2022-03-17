ability_lost_souls = ability_lost_souls or class({})
LinkLuaModifier("modifier_lost_souls", "heroes/davy_jones/ability_lost_souls.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_spectral_empowerment", "heroes/davy_jones/modifier_talent_spectral_empowerment.lua", LUA_MODIFIER_MOTION_NONE)

function ability_lost_souls:GetAbilityTextureName()
   return "lost_souls"
end

function ability_lost_souls:GetIntrinsicModifierName()
	return "modifier_lost_souls"
end

function ability_lost_souls:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end


-- lost souls modifier
modifier_lost_souls = modifier_lost_souls or class({})

function modifier_lost_souls:IsHidden()
	return false
end

function modifier_lost_souls:IsDebuff()
	return false
end

function modifier_lost_souls:IsPurgable()
	return false
end

function modifier_lost_souls:RemoveOnDeath()
	return false
end

function modifier_lost_souls:DeclareFunctions()
	return  {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_lost_souls:OnCreated()
	self.ability = self:GetAbility()

	-- from ability_lost_souls.txt
	self.creep_kill_soul_count 		= self.ability:GetSpecialValueFor("creep_kill_soul_count")
	self.hero_kill_soul_count 		= self.ability:GetSpecialValueFor("hero_kill_soul_count")
	self.damage_per_soul 			= self.ability:GetSpecialValueFor("damage_per_soul")
	self.bonus_per_soul = 0
	if self:GetCaster():HasTalent("talent_spectral_empowerment") then
		self.bonus_per_soul = self:GetCaster():FindTalentValue("talent_spectral_empowerment", "bonus_per_soul")
		print("Bonus Damage of " .. tostring(self.bonus_per_soul))
	end
	self.max_souls 					= self.ability:GetSpecialValueFor("max_souls")
	self.soul_projectile_speed 		= self.ability:GetSpecialValueFor("soul_projectile_speed")
	self.souls_lost_on_death_pct 	= self.ability:GetSpecialValueFor("souls_lost_on_death_pct")

	if IsServer() and self:GetStackCount() == nil then
	 	self:SetStackCount(0)
	end
end

function modifier_lost_souls:OnRefresh()
	print("modifier_lost_souls:OnRefresh()")
	self:OnCreated()
end

function modifier_lost_souls:GetModifierPreAttack_BonusDamage()
	return ((self.damage_per_soul + self.bonus_per_soul) * self:GetStackCount())
end

-- NOTE: This fires any time any unit dies
function modifier_lost_souls:OnDeath( params )
	if IsServer() then

		-- Did we die? ==> lose stacks
		if params.unit == self:GetParent() and params.reincarnate == false then
			local stacks_lost = math.floor(self:GetStackCount() * (self.souls_lost_on_death_pct * 0.01))
			self:SetStackCount(self:GetStackCount() - stacks_lost)
		end

		-- did we kill a real unit? ==> add stacks
		local target = params.unit
		local attacker = params.attacker
		if (	attacker == self:GetParent() 
			and target ~= self:GetParent() 
			and attacker:IsAlive() 
			and (not target:IsIllusion()) 
			and (not target:IsBuilding())
			and (not self:GetParent():PassivesDisabled())) then
				self:AddStack(1)
				-- check if it is a hero
				if target:IsRealHero() then
					self:AddStack(11)
				end

				self:PlayEffects( target )
		end
	end
end

function modifier_lost_souls:AddStack( value )
	local current = self:GetStackCount()
	print("modifier_lost_souls:AddStack(" .. tostring(value) .. ") || current = " .. tostring(current))
	local after = current + value
	--if not self:GetParent():HasScepter() then
	if after > self.max_souls then
		after = self.max_souls
	end
	-- else
	-- 	if after > self.soul_max_scepter then
	-- 		after = self.soul_max_scepter
	-- 	end
	-- end
	self:SetStackCount( after )
end

function modifier_lost_souls:PlayEffects( target )
	-- Get Resources
	local projectile_name = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf"

	-- CreateProjectile
	local info = {
		Target = self:GetParent(),
		Source = target,
		EffectName = projectile_name,
		iMoveSpeed = 400,
		vSourceLoc= target:GetAbsOrigin(),                -- Optional
		bDodgeable = false,                                -- Optional
		bReplaceExisting = false,                         -- Optional
		flExpireTime = GameRules:GetGameTime() + 5,      -- Optional but recommended
		bProvidesVision = false,                           -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)
end