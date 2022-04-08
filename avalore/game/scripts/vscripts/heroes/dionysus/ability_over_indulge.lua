ability_over_indulge = class({})

LinkLuaModifier("modifier_drunk", "heroes/dionysus/modifier_drunk.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_talent_potent_drinks", "heroes/dionysus/modifier_talent_potent_drinks.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_self_inflicted_wounds", "heroes/dionysus/modifier_talent_self_inflicted_wounds.lua", LUA_MODIFIER_MOTION_NONE )

function ability_over_indulge:GetAOERadius()
	return self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("talent_potent_drinks", "bonus_radius")
end


function ability_over_indulge:OnSpellStart()
    self:GetCaster():EmitSound("Hero_Brewmaster.CinderBrew.Cast")

	self.duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("talent_potent_drinks", "bonus_duration")
	self.radius = self:GetSpecialValueFor("radius") + self:GetCaster():FindTalentValue("talent_potent_drinks", "bonus_radius")
	
	local brew_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_cinder_brew_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(brew_particle, 1, self:GetCursorPosition())
	ParticleManager:ReleaseParticleIndex(brew_particle)
	
	if self:GetCaster():GetName() == "npc_dota_hero_brewmaster" then
		if not self.responses then
			self.responses = {
				"brewmaster_brew_ability_drukenhaze_01",
				"brewmaster_brew_ability_drukenhaze_02",
				"brewmaster_brew_ability_drukenhaze_03",
				"brewmaster_brew_ability_drukenhaze_04",
				"brewmaster_brew_ability_drukenhaze_05",
				"brewmaster_brew_ability_drukenhaze_08"
			}
		end
		
		self:GetCaster():EmitSound(self.responses[RandomInt(1, #self.responses)])
	end
		
	-- Preventing projectiles getting stuck in one spot due to potential 0 length vector
	if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end
	
	-- Set up projectile table to track both the final projectile location as well as any hit enemies along the wave
	if not self.projectiles then
		self.projectiles = {}
	end
	
	--"Cinder Brew's projectile travels at a speed of 1600."
	local brew_projectile = ProjectileManager:CreateLinearProjectile({
		EffectName	        = "",
		Ability		        = self,
		Source		        = self:GetCaster(),
		vSpawnOrigin	    = self:GetCaster():GetAbsOrigin(),
		vVelocity	        = ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()) * Vector(1, 1, 0)):Normalized() * 1600,
		vAcceleration	    = nil, --hmm...
		fMaxSpeed	        = nil, -- What's the default on this thing?
		fDistance	        = (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Length2D(),
		fStartRadius	    = self.radius,
		fEndRadius		    = self.radius,
		fExpireTime		    = nil,
		iUnitTargetTeam	    = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bIgnoreSource		= true,
		bHasFrontalCone		= false,
		bDrawsOnMinimap		= false,
		bVisibleToEnemies	= true,
		bProvidesVision		= false,
		iVisionRadius		= nil,
		iVisionTeamNumber	= nil,
		ExtraData			= {}
	})
	
	self.projectiles[brew_projectile] = {}
	self.projectiles[brew_projectile]["destination"] = self:GetCursorPosition()
end

-- Due to some weird logic detailed in the wiki where this doesn't work as a simple "apply immediately to all enemies upon projectile land" but rather like a wave that gradually affects units but only if they're within a radius, going to use a thinker
function ability_over_indulge:OnProjectileThinkHandle(projectileHandle)
	for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), ProjectileManager:GetLinearProjectileLocation(projectileHandle), nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		print("Over Indulge - found unit " .. unit:GetName())
		-- Check if the projectile, the unit, and the final destination radius are all overlapping or not
		if self.projectiles[projectileHandle]["destination"] and ((self.projectiles[projectileHandle]["destination"] - ProjectileManager:GetLinearProjectileLocation(projectileHandle)) * Vector(1, 1, 0)):Length2D() <= self.radius and ((unit:GetAbsOrigin() - ProjectileManager:GetLinearProjectileLocation(projectileHandle)) * Vector(1, 1, 0)):Length2D() <= self.radius and not self.projectiles[projectileHandle][unit:entindex()] then
			self.projectiles[projectileHandle][unit:entindex()]	= true
			
			if unit:IsHero() then
				unit:EmitSound("Hero_Brewmaster.CinderBrew.Target")
			else
				unit:EmitSound("Hero_Brewmaster.CinderBrew.Target.Creep")
			end
			
			if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
				
				unit:AddNewModifier(self:GetCaster(), self, "modifier_drunk", {duration = self.duration * (1 - unit:GetStatusResistance())})
			end
		end
	end
end

function ability_over_indulge:OnProjectileHitHandle(target, location, projectileHandle)
	if not target and location then
		EmitSoundOnLocationWithCaster(location, "Hero_Brewmaster.CinderBrew", self:GetCaster())
		
		for _, unit in pairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, self.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			print("Over Indulge - found unit " .. unit:GetName())
			if not self.projectiles[projectileHandle][unit:entindex()] then
				self.projectiles[projectileHandle][unit:entindex()]	= true
				
				if unit:IsHero() then
					unit:EmitSound("Hero_Brewmaster.CinderBrew.Target")
				else
					unit:EmitSound("Hero_Brewmaster.CinderBrew.Target.Creep")
				end
				
				if unit:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
					
					unit:AddNewModifier(self:GetCaster(), self, "modifier_drunk", {duration = self.duration * (1 - unit:GetStatusResistance())})
				end
			end
		end
		
		self.projectiles[projectileHandle]	= nil
		self.brew_modifier	= nil
	end
end