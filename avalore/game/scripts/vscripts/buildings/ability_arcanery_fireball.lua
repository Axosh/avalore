ability_arcanery_fireball = class({})

function ability_arcanery_fireball:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function ability_arcanery_fireball:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function ability_arcanery_fireball:OnSpellStart()
    -- Preventing projectiles getting stuck in one spot due to potential 0 length vector
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
		self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
	end

    local fireball_target = CreateModifierThinker(self:GetCaster(), self, nil, {
        duration		= FrameTime() -- Don't really need these things to be existing at all except to be a target to go towards
    },
    self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)

    local fireball_dummy = CreateModifierThinker(self:GetCaster(), self, nil, {},	self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

    local fireball_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_snapfire/snapfire_lizard_blobs_arced.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(fireball_particle, 0, self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_rocket")))
    ParticleManager:SetParticleControl(fireball_particle, 1, self:GetCursorPosition())
    ParticleManager:SetParticleControl(fireball_particle, 2, Vector(self:GetTalentSpecialValueFor("projectile_speed"), 0, 0))

    local fireball =
        {
            Target 				= fireball_target,
            Source 				= self:GetCaster(),
            Ability 			= self,
            iMoveSpeed			= self:GetTalentSpecialValueFor("speed"),
            vSourceLoc 			= self:GetCaster():GetAttachmentOrigin(self:GetCaster():ScriptLookupAttachment("attach_rocket")),
            bDrawsOnMinimap 	= true,
            bDodgeable 			= true,
            bIsAttack 			= false,
            bVisibleToEnemies 	= true,
            bReplaceExisting 	= false,
            flExpireTime 		= GameRules:GetGameTime() + 20,
            bProvidesVision 	= true,
            iVisionRadius 		= self:GetSpecialValueFor("vision_radius"),
            iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),

            ExtraData = {fireball_dummy = fireball_dummy:entindex(), fireball_particle = fireball_particle, x = self:GetCaster():GetAbsOrigin().x, y = self:GetCaster():GetAbsOrigin().y, z = self:GetCaster():GetAbsOrigin().z}
        }

    self:GetCaster():EmitSound("Hero_Snapfire.MortimerBlob.Launch")		
    -- -- Arbitrary band-aid fix for lingering sounds when cast too close to caster
    -- if (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Length2D() > 200 then
    --     fireball_dummy:EmitSound("Hero_Rattletrap.Rocket_Flare.Travel")
    -- end		

    ProjectileManager:CreateTrackingProjectile(fireball)

    -- Just in case this thing isn't destroying itself
    fireball_target:RemoveSelf()
end

function ability_arcanery_fireball:OnProjectileThink_ExtraData(vLocation, ExtraData)
	EntIndexToHScript(ExtraData.fireball_dummy):SetAbsOrigin(vLocation)
end


function ability_arcanery_fireball:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
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
	
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), vLocation, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	local damage = self:GetAbilityDamage()
	
	-- Retrieve where the Rocket Flare was originally fired from to check for System Critical IMBAfication
	local cast_position = Vector(ExtraData.x, ExtraData.y, ExtraData.z)
	
	for _, enemy in pairs(enemies) do
		-- Standard damage
		local fireball_damage		= damage
		
		local travel_distance	= (enemy:GetAbsOrigin() - cast_position):Length2D()
		local target_distance	= (enemy:GetAbsOrigin() - vLocation):Length2D()

		local damageTable = {
			victim 			= enemy,
			damage 			= fireball_damage,
			damage_type		= self:GetAbilityDamageType(),
			damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
			attacker 		= self:GetCaster(),
			ability 		= self
		}
		
		ApplyDamage(damageTable)
	end
	
	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("duration"), false)
end