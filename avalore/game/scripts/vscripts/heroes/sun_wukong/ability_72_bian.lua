ability_72_bian = class({})

LinkLuaModifier("modifier_72_bian_fish",       "heroes/sun_wukong/modifier_72_bian_fish.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_72_bian_boar",       "heroes/sun_wukong/modifier_72_bian_boar.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_72_bian_bird",       "heroes/sun_wukong/modifier_72_bian_bird.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_72_bian_tree",       "heroes/sun_wukong/modifier_72_bian_tree.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_fade",       "modifiers/shared/modifier_water_fade.lua",       LUA_MODIFIER_MOTION_NONE)

function ability_72_bian:OnAbilityPhaseInterrupted()
end

function ability_72_bian:OnAbilityPhaseStart()
    if not self:CheckVectorTargetPosition() then return false end
    return true
end

function ability_72_bian:OnSpellStart()
    --local dir_facing = self:GetCaster():GetForwardVector():Normalized() -- get this asap
    local caster = self:GetCaster()
	local target = self:GetVectorTargetPosition()
    --local point = self:GetCursorPosition()
    local direction = target.direction:Normalized()

    local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
    local transformation_time = self:GetSpecialValueFor("transformation_time")

    -- Add cast particle effects
    local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle_cast_fx, 0 , caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 1 , caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 2 , caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle_cast_fx, 3 , caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_cast_fx)

    -- Disjoint projectiles
	ProjectileManager:ProjectileDodge(caster)

    local quadrant = XQuadrantBetween2DVectors(Vector(0,1,0), direction)

    local modifier_transformation = ""

    if quadrant == 0 then
        -- bird form (UP)
        print("Bird Form")
        caster:EmitSound("Hero_Beastmaster.Call.Hawk")
        modifier_transformation = "modifier_72_bian_bird"
    elseif quadrant == 1 then
        -- boar form (RIGHT)
        print("Boar Form")
        modifier_transformation = "modifier_72_bian_boar"
    elseif quadrant == 2 then
        -- tree form (DOWN)
        print("Tree Form")
        modifier_transformation = "modifier_72_bian_tree"
    else
        -- fish form (LEFT)
        print("Fish Form")
        modifier_transformation = "modifier_72_bian_fish"
    end

    -- trigger the transformation buff after the Timer expires
    Timers:CreateTimer(transformation_time, function()
        caster:AddNewModifier(caster, self, modifier_transformation, {})
    end)

    -- disable uncastable spells while transformed + change ability to cancel transform, preserve levels/upgrades
    local spell_slot2 = self:GetCaster():GetAbilityByIndex(2):GetAbilityName() -- 0-indexed
    caster:SwapAbilities(spell_slot2, "ability_72_bian_cancel", false, true)
    local curr_level_slot2 = caster:FindAbilityByName(spell_slot2):GetLevel()
    self:GetCaster():GetAbilityByIndex(2):SetLevel(curr_level_slot2)
    SwapSpells(self, 2, "ability_72_bian_cancel")
end