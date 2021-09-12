ability_riptide = ability_riptide or class({})

LinkLuaModifier( "modifier_knockback_avalore", "scripts/vscripts/modifiers/modifier_knockback_avalore", LUA_MODIFIER_MOTION_BOTH )
--LinkLuaModifier( "modifier_swashbuckle", "heroes/robin_hood/modifier_swashbuckle.lua", LUA_MODIFIER_MOTION_NONE )

-- ==================================================
-- Ability Phase Start
-- ==================================================
-- function ability_riptide:OnAbilityPhaseInterrupted()

-- end
-- function ability_riptide:OnAbilityPhaseStart()
-- 	-- Vector targeting
-- 	if not self:CheckVectorTargetPosition() then return false end
-- 	return true -- if success
-- end

-- ==================================================
-- Ability Start
-- ==================================================
function ability_riptide:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local targets = self:GetVectorTargetPosition()
    local point = self:GetCursorPosition()

    local name = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf"
    local speed = self:GetSpecialValueFor("speed")
	local radius = self:GetSpecialValueFor("aoe")
    local range = 700 --temp value for testing --self:GetCastRange( point, target )

    local direction = targets.direction

    local vector = (targets.init_pos-caster:GetOrigin())
	local dist = vector:Length2D()
	vector.z = 0
	vector = vector:Normalized()

    -- create linear projectile
    local info = {
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetAbsOrigin(),
    
        bDeleteOnHit = false,
    
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    
        EffectName = name,
        fDistance = range,
        fStartRadius = radius,
        fEndRadius = radius,
        vVelocity = direction * speed,
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
	local duration = 2

		-- provide vision
	AddFOWViewer( self:GetCaster():GetTeamNumber(), target:GetOrigin(), vision, duration, true )
end