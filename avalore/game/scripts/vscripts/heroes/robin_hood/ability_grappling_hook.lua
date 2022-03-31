
ability_grappling_hook = ability_grappling_hook or class({})
LinkLuaModifier( "modifier_grappling_hook", "heroes/robin_hood/modifier_grappling_hook.lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_talent_escape_artist", "heroes/robin_hood/modifier_talent_escape_artist.lua", LUA_MODIFIER_MOTION_HORIZONTAL )

function ability_grappling_hook:OnSpellStart()
    local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_distance = self:GetSpecialValueFor( "range" ) + self:GetCaster():FindTalentValue("talent_escape_artist", "range_bonus")
	local projectile_radius = self:GetSpecialValueFor( "radius" )
	local projectile_direction = point-caster:GetOrigin()
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	local tree_radius = self:GetSpecialValueFor( "chain_radius" )
	local vision = 100

	-- create effect
	local effect = self:PlayEffects( caster:GetOrigin() + projectile_direction * projectile_distance, projectile_speed, projectile_distance/projectile_speed )

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
		bDeleteOnHit = false,

		EffectName = "",
		fDistance = projectile_distance,
		fStartRadius = projectile_radius,
		fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = vision,
		iVisionTeamNumber = caster:GetTeamNumber(),
	}

	-- register projectile
	local projectile = ProjectileManager:CreateLinearProjectile(info)
	local ExtraData = {
		effect = effect,
		radius = tree_radius,
	}
	self.projectiles[ projectile ] = ExtraData
end

function ability_grappling_hook:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor( "range" ) + self:GetCaster():FindTalentValue("talent_escape_artist", "range_bonus")
end

function ability_grappling_hook:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel) - self:GetCaster():FindTalentValue("talent_escape_artist", "cooldown_reduction")
end

local function concatArray(a, b)
	local mergedArray = {}
	local n=0
	for k,v in ipairs(a) do n=n+1 ; mergedArray[n] = v end
	for k,v in ipairs(b) do n=n+1 ; mergedArray[n] = v end
	return mergedArray
	-- local result = {table.unpack(a)}
	-- table.move(b, 1, #b, #result + 1, result)
	-- return result
end

--------------------------------------------------------------------------------
-- Projectile
ability_grappling_hook.projectiles = {}
function ability_grappling_hook:OnProjectileThinkHandle( handle )
	-- get data
	local ExtraData = self.projectiles[ handle ]
	local location = ProjectileManager:GetLinearProjectileLocation( handle )

	-- search for tree
	local trees = GridNav:GetAllTreesAroundPoint( location, ExtraData.radius, false )
	
	-- find nearby structures
	local buildings = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		location, --target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		ExtraData.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE, --0,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)

	local trees_buildings = concatArray(trees, buildings)

	--if #trees>0 then
	if #trees_buildings > 0 then
		print("Grapple Target: " .. trees_buildings[1]:GetName())
		--local point = trees[1]:GetOrigin()
		local point = trees_buildings[1]:GetOrigin()

		-- snag
		self:GetCaster():AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_grappling_hook", -- modifier name
			{
				point_x = point.x,
				point_y = point.y,
				point_Z = point.z,
				effect = ExtraData.effect,
			} -- kv
		)

		-- modify effects
		self:ModifyEffects2( ExtraData.effect, point )

		-- destroy projectile
		ProjectileManager:DestroyLinearProjectile( handle )
		self.projectiles[ handle ] = nil

		-- add vision
		AddFOWViewer( self:GetCaster():GetTeamNumber(), point, 400, 1, true )
	end
end

function ability_grappling_hook:OnProjectileHitHandle( target, location, handle )
	local ExtraData = self.projectiles[ handle ]
	if not ExtraData then return end

	-- add vision
	AddFOWViewer( self:GetCaster():GetTeamNumber(), location, 400, 0.1, true )

	-- play effect
	self:ModifyEffects1( ExtraData.effect )

	-- destroy reference
	self.projectiles[ handle ] = nil
end

--------------------------------------------------------------------------------
function ability_grappling_hook:PlayEffects( point, speed, duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_shredder/shredder_timberchain.vpcf"
	--local particle_cast = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot_trail_rubick.vpcf"
	local sound_cast = "Hero_Shredder.TimberChain.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, point )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( speed, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 3, Vector( duration*2 + 0.3, 0, 0 ) )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	return effect_cast
end

function ability_grappling_hook:ModifyEffects1( effect )
	-- retract
	ParticleManager:SetParticleControlEnt(
		effect,
		1,
		self:GetCaster(),
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect )

	-- play sound
	local sound_cast = "Hero_Shredder.TimberChain.Retract"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function ability_grappling_hook:ModifyEffects2( effect, point )
	-- set particle location
	ParticleManager:SetParticleControl( effect, 1, point )

	-- increase effect duration
	ParticleManager:SetParticleControl( effect, 3, Vector( 20, 0, 0 ) )

	-- play sound
	local sound_cast = "Hero_Shredder.TimberChain.Retract"
	local sound_target = "Hero_Shredder.TimberChain.Impact"
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOnLocationWithCaster( point, sound_target, self:GetCaster() )
end
