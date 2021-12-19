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
        -- vault logic
        local vault_dir = Vector(direction.x * -1, direction.y * -1, direction.z)
        PrintVector((vault_dir * self:GetSpecialValueFor("vault_max_distance")), "Vector to Add")
        local target_point = caster:GetAbsOrigin() + (vault_dir * self:GetSpecialValueFor("vault_max_distance"))

        --caster:StartGesture(ACT_DOTA_MK_SPRING_SOAR)
        --caster:StartGesture(ACT_DOTA_MK_STRIKE)
        caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1  )
        --caster:StartGestureWithPlaybackRate(ACT_DOTA_MK_STRIKE, 2.0)
        --caster:FaceTowards(target_point)

        -- Start moving
	    --local modifier_movement_handler = caster:AddNewModifier(caster, self, "modifier_jingu_vault", 
        caster:AddNewModifier(caster, self, "modifier_jingu_vault",
        {
            target_point_x = target_point.x,
            target_point_y = target_point.y,
            target_point_z = target_point.z
        })

        -- -- Assign the target location in the modifier
        -- if modifier_movement_handler then
        --     -- can't pass Vector (since it's an object), so break down to components and re-assemble later
        --     modifier_movement_handler.target_point_x = target_point.x
        --     modifier_movement_handler.target_point_y = target_point.y
        --     modifier_movement_handler.target_point_z = target_point.z
        -- end
    else
        -- slam logic
    end
end