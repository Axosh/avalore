ability_arcanery_fireball = class({})

LinkLuaModifier( "modifier_knockback_avalore", "scripts/vscripts/modifiers/modifier_knockback_avalore", LUA_MODIFIER_MOTION_BOTH )

function ability_arcanery_fireball:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function ability_arcanery_fireball:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

-- the built in kv didn't seem to be working for a building
function ability_arcanery_fireball:GetManaCost(iLevel)
	return self:GetSpecialValueFor("mana_cost")
end

function ability_arcanery_fireball:OnSpellStart()
    local caster = self:GetCaster()
    local target_temp = Vector(caster.target_x, caster.target_y, 0) -- this comes in from the OrderFilter capturing the player's cursor
    print("Target => " .. tostring(target_temp))
    local target = GetGroundPosition(target_temp, nil) -- get z-coord

	-- mana isn't updating correctly
	self:GetCaster():SetMana( self:GetCaster():GetMana() -  self:GetSpecialValueFor("mana_cost"))
	-- Set the mana on this unit.

    -- self:SetCursorPosition(target)

    -- -- Preventing projectiles getting stuck in one spot due to potential 0 length vector
    -- if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
	-- 	self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	-- end

    local fireball_target = CreateModifierThinker(	self:GetCaster(), --player source
													self, --ability
													nil, --modifier name
													-- param table
													{
            											--duration = GameRules:GetGameTime() + 20,
            											duration		= FrameTime() -- Don't really need these things to be existing at all except to be a target to go towards
													},
													target, --origin
													self:GetCaster():GetTeamNumber(), --team
													false --phantom blocker
												);

    local fireball_dummy = CreateModifierThinker(  	self:GetCaster(),
													self,
													nil,
													{},
													self:GetCaster():GetAbsOrigin(),
													self:GetCaster():GetTeamNumber(),
													false
												)

    local fireball_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(fireball_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_rocket")))
    ParticleManager:SetParticleControl(fireball_particle, 1, target)
    ParticleManager:SetParticleControl(fireball_particle, 2, Vector(self:GetSpecialValueFor("projectile_speed"), 0, 0))

    local fireball =
        {
            Target 				= fireball_target,
            Source 				= self:GetCaster(),
            Ability 			= self,
            iMoveSpeed			= self:GetTalentSpecialValueFor("projectile_speed"),
            --vSourceLoc 			= self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_rocket")),
            vSourceLoc          = self:GetCaster():GetOrigin(),
            bDrawsOnMinimap 	= true,
            bDodgeable 			= true,
            bIsAttack 			= false,
            bVisibleToEnemies 	= true,
            bReplaceExisting 	= false,
            flExpireTime 		= GameRules:GetGameTime() + 20,
            bProvidesVision 	= true,
            iVisionRadius 		= self:GetSpecialValueFor("vision"),
            iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),

			-- iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			-- iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			-- iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,

            ExtraData = 
						{ fireball_dummy = fireball_dummy:entindex(),
						  fireball_particle = fireball_particle,
						  x = self:GetCaster():GetAbsOrigin().x,
						  y = self:GetCaster():GetAbsOrigin().y,
						  z = self:GetCaster():GetAbsOrigin().z
						}
        }

    self:GetCaster():EmitSound("Hero_Snapfire.MortimerBlob.Launch")		
    -- -- Arbitrary band-aid fix for lingering sounds when cast too close to caster
    -- if (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Length2D() > 200 then
    --     fireball_dummy:EmitSound("Hero_Rattletrap.Rocket_Flare.Travel")
    -- end		

    self.projectile = ProjectileManager:CreateTrackingProjectile(fireball)
	self.target = target

    -- Just in case this thing isn't destroying itself
    fireball_target:RemoveSelf()
end

function ability_arcanery_fireball:OnProjectileThink_ExtraData(vLocation, ExtraData)
	local unit = EntIndexToHScript(ExtraData.fireball_dummy)
	local location_to_ground_level = GetGroundPosition(vLocation, unit)
	unit:SetAbsOrigin(location_to_ground_level)
	--EntIndexToHScript(ExtraData.fireball_dummy):SetAbsOrigin(vLocation)
end

-- Projectile has collided with a given target or reached its destination. If 'true` is returned, projectile would be destroyed.
function ability_arcanery_fireball:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    print("function ability_arcanery_fireball:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)")
    ParticleManager:DestroyParticle(ExtraData.fireball_particle, false)
	ParticleManager:ReleaseParticleIndex(ExtraData.fireball_particle)
	
	--EntIndexToHScript(ExtraData.rocket_dummy):StopSound("Hero_Rattletrap.Rocket_Flare.Travel")
	EntIndexToHScript(ExtraData.fireball_dummy):RemoveSelf()
	EmitSoundOnLocationWithCaster(vLocation, "Hero_Snapfire.MortimerBlob.Impact", self:GetCaster())
	
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
    -- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, vLocation )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, vLocation )
	ParticleManager:SetParticleControl( effect_cast, 1, vLocation )
	ParticleManager:ReleaseParticleIndex( effect_cast )

--	print("Radi => " .. tostring(self:GetSpecialValueFor("radius")))
	local radius = self:GetSpecialValueFor("radius")
	
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), 
										vLocation, 
										nil, 
										radius, 
										DOTA_UNIT_TARGET_TEAM_ENEMY, 
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 
										DOTA_UNIT_TARGET_FLAG_NONE, 
										FIND_ANY_ORDER, false)
	
	local damage = self:GetSpecialValueFor( "damage" )
	--print("damage => " .. tostring(damage))
	
	for _, enemy in pairs(enemies) do
		--print("Hit Enemy " .. enemy:GetName())
		-- Standard damage
		local fireball_damage		= damage

		local damageTable = {
			victim 			= enemy,
			damage 			= fireball_damage,
			damage_type		= self:GetAbilityDamageType(),
			--damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self
		}
		
		ApplyDamage(damageTable)

		-- knockback
		local knockbackMax = self:GetSpecialValueFor("knockback_distance_max")
		local knockbackDur = self:GetSpecialValueFor("knockback_duration")
		--print("Enemy Vect => " .. tostring(enemy:GetOrigin()))
		local distFromImpact = enemy:GetOrigin()-Vector(vLocation.x,vLocation.y,0)
		distFromImpact.z = 0
		local dist2d = distFromImpact:Length2D()
		--print("len 2d => " .. tostring(dist2d))
		--dist = (1 - dist / radius) * knockbackMax
		local dist = (((radius - dist2d) + 1) / radius) * knockbackMax
		--print("dist => " .. tostring(dist))

		-- apply knockback
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_knockback_avalore", -- modifier name
			{
				duration = knockbackDur,
				distance = dist,
				direction_x = distFromImpact.x,
				direction_y = distFromImpact.y,
			} -- kv
		)
	end
	
	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("duration"), false)

    self:PlayEffects(vLocation)
end

function ability_arcanery_fireball:PlayEffects( loc )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_impact.vpcf"
	local particle_cast2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ultimate_linger.vpcf"
	local sound_cast = "Hero_Snapfire.MortimerBlob.Impact"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 3, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local effect_cast = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, loc )
	ParticleManager:SetParticleControl( effect_cast, 1, loc )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	local sound_location = "Hero_Snapfire.MortimerBlob.Impact"
	EmitSoundOnLocationWithCaster( loc, sound_location, self:GetCaster() )
end