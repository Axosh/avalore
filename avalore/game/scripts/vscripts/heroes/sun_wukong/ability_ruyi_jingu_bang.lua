require("references")
require(REQ_LIB_TIMERS)

ability_ruyi_jingu_bang = class({})

LinkLuaModifier("modifier_jingu_vault",       "heroes/sun_wukong/modifier_jingu_vault.lua",       LUA_MODIFIER_MOTION_NONE)
-- Note: this gets handled in filters
LinkLuaModifier( "modifier_ignore_cast_direction", "scripts/vscripts/modifiers/modifier_ignore_cast_direction.lua", LUA_MODIFIER_MOTION_NONE )

function ability_ruyi_jingu_bang:OnAbilityPhaseInterrupted()
end

function ability_ruyi_jingu_bang:OnAbilityPhaseStart()
    -- vector targeting
    if not self:CheckVectorTargetPosition() then return false end
    return true -- success
end

function ability_ruyi_jingu_bang:OnSpellStart()
    local dir_facing = self:GetCaster():GetForwardVector():Normalized() -- get this asap
    local caster = self:GetCaster()
	local target = self:GetVectorTargetPosition()
    local point = self:GetCursorPosition()

    --caster:Stop() -- try to prevent turning around (doesn't work)

    -- determine if we're vaulting or slammin'
    -- check if vector direction is same or opposite of the way the unit is facing
    local direction = target.direction:Normalized()
    
    PrintVector(target.direction, "Target Direction")
    PrintVector(target.direction:Normalized(), "Target Direction (Normalized)")

    -- facing same direction? (idk if best way to do it)
    print("Vector Y = " .. tostring(direction.y))
    print("Facing Y = " .. tostring(dir_facing.y))
    local octant = OctantBetween2DVectors(dir_facing, direction)
    print("octant = " .. tostring(octant))
    -- if (direction.y > 0 and dir_facing.y > 0) or (direction.y == dir_facing.y) or (direction.y < 0 and dir_facing.y < 0) then
    --     -- slam logic
    --     print("TODO: SLam Logic")
    -- else
    if octant > 2 and octant < 6 then
        -- vault logic (vector pulled away from facing direction)
        local vault_dir = Vector(direction.x * -1, direction.y * -1, direction.z)
        --local vault_dir = Vector(math.floor(direction.x * -10)/10, math.floor(direction.y * -10)/10, direction.z)
        PrintVector(vault_dir, "Vault Dir")
        local intensity = TargetingVectorIntensity(target)
        PrintVector((vault_dir * intensity * self:GetSpecialValueFor("vault_max_distance")), "Vector to Add")
        local target_point = caster:GetAbsOrigin() + (vault_dir * intensity *  self:GetSpecialValueFor("vault_max_distance"))

        --caster:StartGesture(ACT_DOTA_MK_SPRING_SOAR)
        --caster:StartGesture(ACT_DOTA_MK_STRIKE)
        caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1  )
        --caster:StartGestureWithPlaybackRate(ACT_DOTA_MK_STRIKE, 2.0)
        --caster:FaceTowards(target_point)

        -- Start moving
	    --local modifier_movement_handler = caster:AddNewModifier(caster, self, "modifier_jingu_vault", 
        local mod_vault = caster:AddNewModifier(caster, self, "modifier_jingu_vault",
        {
            target_point_x = target_point.x,
            target_point_y = target_point.y,
            target_point_z = target_point.z
        })

        local radius = self:GetSpecialValueFor("vault_impact_radius")
        local damage = self:GetSpecialValueFor("vault_impact_dmg")

        -- apply AoE damage after vaulting is finished
        local callback = function()
            -- find units
            local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(),	-- int, your team number
                caster:GetOrigin(),	-- point, center point
                nil,	-- handle, cacheUnit. (not known)
                radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
                DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
                0,	-- int, flag filter
                0,	-- int, order filter
                false	-- bool, can grow cache
            )

            -- precache damage
            local damageTable = {
                -- victim = target,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                ability = self, --Optional.
            }

            for _,enemy in pairs(enemies) do
                -- damage
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end

            -- play effects
            self:PlayEffects( caster:GetAbsOrigin(), radius )
        end

        mod_vault:SetEndCallback(callback)

        -- -- Assign the target location in the modifier
        -- if modifier_movement_handler then
        --     -- can't pass Vector (since it's an object), so break down to components and re-assemble later
        --     modifier_movement_handler.target_point_x = target_point.x
        --     modifier_movement_handler.target_point_y = target_point.y
        --     modifier_movement_handler.target_point_z = target_point.z
        -- end
    else
        -- slam logic
        local slam_speed = self:GetSpecialValueFor("slam_speed")
        local slam_radius = self:GetSpecialValueFor("slam_radius")
        local slam_max_dist = self:GetSpecialValueFor("slam_max_distance")
        local slam_max_damage = self:GetSpecialValueFor("slam_max_damage")
        local slam_max_stun = self:GetSpecialValueFor("slam_max_stun")
        print("Max Dist = " .. tostring(slam_max_dist))
        --local slam_time = 1.0
        local distance = (caster:GetAbsOrigin() - target.end_pos):Length2D()
        local dir = (target.end_pos - caster:GetAbsOrigin()):Normalized()
        local end_point = target.end_pos

        if distance > slam_max_dist then
            distance = slam_max_dist
            end_point = ResolveEndPoint(caster:GetAbsOrigin(), dir, slam_max_dist)
            PrintVector(caster:GetAbsOrigin(), "Start Point")
            PrintVector(end_point, "New End Point")
        end

        local scale = distance/slam_max_dist
        -- invert it and buffer it
        scale = 1 - scale
        if scale < 0.3 then
            scale = 0.3
        elseif scale > 0.8 then
            scale = 1.0
        end


        
        -- Add particle effect
        -- TODO: have the polearm scale with the distance
        caster:FaceTowards(target.end_pos)
        Timers:CreateTimer(0.2,function ()
            local p1 = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf",PATTACH_ABSORIGIN,caster)
            ParticleManager:SetParticleControlForward(p1,0,target.direction)
            ParticleManager:SetParticleControl(p1, 1, end_point)
            ParticleManager:SetParticleControl(p1, 2, end_point)
        end)
        caster:StartGesture(ACT_DOTA_MK_STRIKE  )
        -- local particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike_cast.vpcf", PATTACH_WORLDORIGIN, caster)
        -- ParticleManager:SetParticleControlForward(particle_fx, 0, target.direction)
        -- local particle_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_strike.vpcf", PATTACH_WORLDORIGIN, caster)
        -- ParticleManager:SetParticleControl(particle_fx, 0, caster:GetAbsOrigin())
        -- -- ParticleManager:SetParticleControlEnt(particle_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
        -- -- ParticleManager:SetParticleControlEnt(particle_fx, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
        -- -- ParticleManager:ReleaseParticleIndex(particle_fx)
        -- --ParticleManager:SetParticleControlEnt(particle_fx, 1, target.end_pos, PATTACH_POINT_FOLLOW, "attach_weapon_bot", caster:GetAbsOrigin(), true)
        -- ParticleManager:SetParticleControl(particle_fx, 1, target.end_pos)
        -- ParticleManager:SetParticleControl(particle_fx, 2, target.end_pos)
        -- --ParticleManager:SetParticleControlEnt(particle_fx, 2, target.end_pos, PATTACH_POINT_FOLLOW, "attach_weapon_top", caster:GetAbsOrigin(), true)
        -- ParticleManager:ReleaseParticleIndex(particle_fx)
        -- -- ParticleManager:SetParticleControl(particle_fx, 0, caster:GetAbsOrigin())
        -- --ParticleManager:SetParticleControl(particle_fx, 1, target.end_pos)
        
        -- Projectile information
        local projectile = {Ability = self,         
                            vSpawnOrigin = caster:GetAbsOrigin(),
                            fDistance = distance,
                            fStartRadius = slam_radius,
                            fEndRadius = slam_radius,
                            Source = caster,
                            bHasFrontalCone = false,
                            bReplaceExisting = false,
                            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,                          
                            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,                           
                            bDeleteOnHit = false,
                            vVelocity = dir * slam_speed * Vector(1, 1, 0),
                            bProvidesVision = false,
                            ExtraData =
                            {
                                scaled_damage = (slam_max_damage * scale),
                                scaled_stun = (slam_max_stun * scale)
                            }
                        }

        ProjectileManager:CreateLinearProjectile(projectile)
    end
end

function ability_ruyi_jingu_bang:OnProjectileHit_ExtraData(target, location, data)
    if not target then
		return nil
	end

	-- If the target is spell immune, do nothing
	if target:IsMagicImmune() then
		return nil
	end

	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
    --local damage = ability:GetSpecialValueFor("vault_impact_dmg")
    local damage = data.scaled_damage

    -- Deal damage
	local damageTable = {victim = target,
                        attacker = caster, 
                        damage = damage,
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability
    }

    ApplyDamage(damageTable)  
end

function ability_ruyi_jingu_bang:PlayEffects( point, radius )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_monkey_king/monkey_king_spring.vpcf"
	local sound_cast = "Hero_MonkeyKing.Spring.Impact"

	-- Get Data
	local caster = self:GetCaster()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, point )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( point, sound_cast, caster )
end