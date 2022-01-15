ability_hammer_toss = class({})

LinkLuaModifier("modifier_no_hammer", "heroes/thor/modifier_no_hammer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hammer_toss_thinker", "heroes/thor/modifier_hammer_toss_thinker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hammer_trail", "heroes/thor/modifier_hammer_trail.lua", LUA_MODIFIER_MOTION_NONE)


function ability_hammer_toss:Precache( context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_grounded.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_trail.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf", context )
end

--------------------------------------------------------------------------------
-- Ability Cast Filter
function ability_hammer_toss:CastFilterResultLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_no_hammer" ) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function ability_hammer_toss:GetCustomCastErrorLocation( vLoc )
	-- check nohammer
	if self:GetCaster():HasModifier( "modifier_no_hammer" ) then
		return "#dota_hud_error_nohammer"
	end

	return ""
end

function ability_hammer_toss:OnSpellStart()
	local caster 	= self:GetCaster()
	local point = self:GetCursorPosition()
	--local target 	= self:GetVectorTargetPosition()
	local radius 	= self:GetSpecialValueFor( "projectile_radius" )
	local speed 	= self:GetSpecialValueFor( "projectile_speed" )
	local distance 	= self:GetSpecialValueFor( "range" )
	local name = ""

	--local direction = target.direction:Normalized()

	-- get direction
	local direction = point-caster:GetOrigin()
	local len = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	distance = math.min( distance, len )

	-- create thinker
	local thinker = CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_hammer_toss_thinker", -- modifier name
		{}, -- kv
		caster:GetOrigin(),
		self:GetCaster():GetTeamNumber(),
		false
	)

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
	
		-- bDeleteOnHit = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	
		EffectName = name,
		fDistance = distance,
		fStartRadius = radius,
		fEndRadius = radius,
		vVelocity = direction * speed,
	}
	local data = {
		cast = 1,
		targets = {},
		thinker = thinker,
	}

	local id = ProjectileManager:CreateLinearProjectile( info )
	thinker.id = id
	self.projectiles[id] = data
	table.insert( self.thinkers, thinker )

	-- set no hammer
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_no_hammer", -- modifier name
		{} -- kv
	)

	-- play effects
	data.effect = self:PlayEffects1( caster:GetOrigin(), distance, direction * speed )
end

--------------------------------------------------------------------------------
-- Projectile
ability_hammer_toss.projectiles = {}
ability_hammer_toss.thinkers = {}
function ability_hammer_toss:OnProjectileThinkHandle( handle )
	local data = self.projectiles[handle]
	if data.thinker:IsNull() then return end

	if data.cast==1 then
		local location = ProjectileManager:GetLinearProjectileLocation( handle )
		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )

	elseif data.cast==2 then
		local location = ProjectileManager:GetTrackingProjectileLocation( handle )
		local radius = self:GetSpecialValueFor( "projectile_radius" )

		-- move thinker along projectile
		data.thinker:SetOrigin( location )

		-- find enemies not yet hit
		local enemies = FindUnitsInRadius(
			self:GetCaster():GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,enemy in pairs(enemies) do
			if not data.targets[enemy] then
				data.targets[enemy] = true

				-- hammer hit
				self:HammerHit( enemy, location )
			end
		end

		-- destroy trees
		local radius = self:GetSpecialValueFor( "projectile_radius" )
		GridNav:DestroyTreesAroundPoint( location, radius, false )
	end
end

function ability_hammer_toss:OnProjectileHitHandle( target, location, handle )
	local data = self.projectiles[handle]
	if not handle then return end

	if data.cast==1 then
		if target then
			self:HammerHit( target, location )
			return false
		end

		-- set thinker origin
		local loc = GetGroundPosition( location, self:GetCaster() )
		data.thinker:SetOrigin( loc )

		-- begin delay
		local mod = data.thinker:FindModifierByName( "modifier_hammer_toss_thinker" )
		mod:Delay()

		-- stop effect
		self:StopEffects( data.effect )

		-- destroy handle
		self.projectiles[handle] = nil

	elseif data.cast==2 then
		local caster = self:GetCaster()

		-- destroy thinker
		for i,thinker in pairs(self.thinkers) do
			if thinker == data.thinker then
				table.remove( self.thinkers, i )
				break
			end
		end
		local mod = data.thinker:FindModifierByName( "modifier_hammer_toss_thinker" )
		mod:Destroy()

		-- -- reset sub-ability
		-- local ability = caster:FindAbilityByName( "dawnbreaker_converge_lua" )
		-- if ability then
		-- 	caster:SwapAbilities(
		-- 		"dawnbreaker_celestial_hammer_lua",
		-- 		"dawnbreaker_converge_lua",
		-- 		true,
		-- 		false
		-- 	)
		-- end

		-- remove nohammer
		local nohammer = caster:FindModifierByName( "modifier_no_hammer" )
		if nohammer then
			nohammer:Decrement()
		end

		-- -- destroy converge modifier
		-- local converge = caster:FindModifierByName( "modifier_dawnbreaker_celestial_hammer_lua" )
		-- if converge then
		-- 	converge:Destroy()
		-- end

		-- destroy handle
		self.projectiles[handle] = nil

		-- play effects
		self:PlayEffects3()
	end
end

function ability_hammer_toss:HammerHit( target, location )
	local damage = self:GetSpecialValueFor( "hammer_damage" )

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- play effects
	self:PlayEffects2( target )
end

function ability_hammer_toss:PlayEffects1( start, distance, velocity )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_projectile.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Cast"

	-- Get Data
	local min_rate = 1
	local duration = distance/velocity:Length2D()
	local rotation = 0.5

	local rate = rotation/duration
	while rate<min_rate do
		rotation = rotation + 1
		rate = rotation/duration
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( effect_cast, 0, start )
	ParticleManager:SetParticleControl( effect_cast, 1, velocity )
	ParticleManager:SetParticleControl( effect_cast, 4, Vector( rate, 0, 0 ) )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )

	return effect_cast
end

function ability_hammer_toss:PlayEffects2( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_celestial_hammer_aoe_impact.vpcf"
	local sound_cast = "Hero_Dawnbreaker.Celestial_Hammer.Damage"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, target )
end

function ability_hammer_toss:PlayEffects3()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge.vpcf"

	-- Get Data
	local radius = self:GetSpecialValueFor( "projectile_radius" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		hTarget,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function ability_hammer_toss:StopEffects( effect )
	ParticleManager:DestroyParticle( effect, false )
	ParticleManager:ReleaseParticleIndex( effect )
end