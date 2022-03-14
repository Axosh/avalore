ability_riptide = ability_riptide or class({})

LinkLuaModifier( "modifier_knockback_avalore", "scripts/vscripts/modifiers/modifier_knockback_avalore", LUA_MODIFIER_MOTION_BOTH )
--LinkLuaModifier( "modifier_swashbuckle", "heroes/robin_hood/modifier_swashbuckle.lua", LUA_MODIFIER_MOTION_NONE )

-- ==================================================
-- Ability Phase Start
-- ==================================================
function ability_riptide:OnAbilityPhaseInterrupted()

end
function ability_riptide:OnAbilityPhaseStart()
	-- Vector targeting
	if not self:CheckVectorTargetPosition() then return false end
	return true -- if success
end

-- ==================================================
-- Ability Start
-- ==================================================
function ability_riptide:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetVectorTargetPosition()
    local point = self:GetCursorPosition()

    local name = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf"
    local speed = self:GetSpecialValueFor("projectile_speed")
	local radius = self:GetSpecialValueFor("projectile_aoe")
    local range = self:GetSpecialValueFor("cast_range") --self:GetCastRange( point, target )

    --local direction = target.direction
    -- Testing - use caster location
    -- local projectile_distance = self:GetCastRange( point, nil )
	-- local projectile_direction = point-caster:GetOrigin()
	-- projectile_direction.z = 0
	-- projectile_direction = projectile_direction:Normalized()

    -- local vector = (targets.init_pos - point)
	-- --local dist = vector:Length2D()
	-- vector.z = 0
	-- vector = vector:Normalized()

    -- create linear projectile
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if self:GetCaster():HasTalent("talent_surf") then
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH
	end

    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = target.init_pos, --caster:GetAbsOrigin(), --vector, 
    
        bDeleteOnHit = false,
    
        iUnitTargetTeam = target_team,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    
        EffectName = name,
        fDistance = range,
        fStartRadius = radius,
        fEndRadius = radius,
        vVelocity = target.direction * speed,
        --vVelocity = projectile_direction * speed,
        --vVelocity = direction * speed,

        ExtraData = {
            --x = caster:GetOrigin().x,
			--y = caster:GetOrigin().y,
			 x = target.init_pos.x,
			 y = target.init_pos.y
            --vec = vector
		}
    }
    ProjectileManager:CreateLinearProjectile( info )

    -- play effects
	local sound_cast = "Ability.GushCast"
	EmitSoundOn( sound_cast, self:GetCaster() )
end

-- ==================================================
-- Projectile
-- ==================================================

function ability_riptide:OnProjectileHit_ExtraData( target, location, data )
    if not target then return end

    local vision = 200
    local max_dist = self:GetSpecialValueFor( "knockback_distance_max" )

	local duration = 2
	if target:GetTeam() == self:GetCaster():GetTeam() then
		if self:GetCaster():HasTalent("talent_surf") then
			duration = 0.35 -- basically a result of experimentation of "what looks right"
		end
	end

		-- provide vision
	AddFOWViewer( self:GetCaster():GetTeamNumber(), target:GetOrigin(), vision, duration, true )

    -- local vector = data.vec --target:GetOrigin()-Vector(data.x,data.y,0)
    -- vector.z = 0
    -- distance = (1-distance/self:GetCastRange( Vector(0,0,0), nil ))*max_dist
	-- if max_dist<0 then distance = 0 end
	-- vector = vector:Normalized()

    local vec = target:GetOrigin()-Vector(data.x,data.y,0)
	vec.z = 0
	local distance = vec:Length2D()
	distance = (1-distance/self:GetCastRange( Vector(0,0,0), nil ))*max_dist
	if max_dist<0 then distance = 0 end
	--vector = vec:Normalized()

    -- apply knockback
	target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_knockback_avalore", -- modifier name
		{
			duration = duration,
			distance = distance,
			direction_x = vec.x,
			direction_y = vec.y,
		} -- kv
	)

	local damage = self:GetSpecialValueFor("riptide_damge")

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

    -- play effects
	self:PlayEffects( target )
end

function ability_riptide:PlayEffects( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_tidehunter/tidehunter_gush_splash.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		3,
		target,
		PATTACH_ABSORIGIN_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )
end