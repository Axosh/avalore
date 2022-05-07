ability_lightning_bolt = class({})

LinkLuaModifier("modifier_lightning_true_sight", "heroes/zeus/modifier_lightning_true_sight.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lightning_bolt",       "heroes/zeus/modifier_lightning_bolt.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_static_field",       "heroes/zeus/modifier_talent_static_field.lua",       LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_chain_lightning",       "heroes/zeus/modifier_talent_chain_lightning.lua",       LUA_MODIFIER_MOTION_NONE)

function ability_lightning_bolt:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Hero_Zuus.LightningBolt.Cast")

	return true
end

function ability_lightning_bolt:CastFilterResultTarget( target )
	if IsServer() then
		if target ~= nil
		and target:IsMagicImmune()
		then
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end
		
		local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
		return nResult
	end
end

function ability_lightning_bolt:OnSpellStart()
	if not IsServer() then return end
    local caster 		= self:GetCaster()
    local target 		= self:GetCursorTarget()
    local target_point 	= self:GetCursorPosition()

    ability_lightning_bolt:LightningBolt(caster, self, target, target_point)
end

function ability_lightning_bolt:LightningBolt(caster, ability, target, target_point, storm_cloud)
    if not IsServer() then return end

    local spread_aoe 			= ability:GetSpecialValueFor("spread_aoe")
    local true_sight_radius 	= ability:GetSpecialValueFor("true_sight_radius")
    local sight_radius_day  	= ability:GetSpecialValueFor("sight_radius_day")
    local sight_radius_night  	= ability:GetSpecialValueFor("sight_radius_night")
    local sight_duration 		= ability:GetSpecialValueFor("sight_duration")
    local stun_duration 		= ability:GetSpecialValueFor("stun_duration")

    local pierce_spellimmunity 	= false
    local z_pos 				= 2000

    if storm_cloud then
        storm_cloud:EmitSound("Hero_Zuus.LightningBolt")
    else
        caster:EmitSound("Hero_Zuus.LightningBolt")
    end

    AddFOWViewer(caster:GetTeam(), target_point, true_sight_radius, sight_duration, false)

    -- Spell was used on the ground search for invisible hero to target
    if target == nil then
        local target_flags = DOTA_UNIT_TARGET_FLAG_NONE
        if pierce_spellimmunity == true then 
            target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        -- Finds all heroes in the radius (the closest hero takes priority over the closest creep)
        local nearby_enemy_units = FindUnitsInRadius(
            caster:GetTeamNumber(), 
            target_point, 
            nil, 
            spread_aoe, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO, 
            target_flags, 
            FIND_CLOSEST, 
            false
        )
        
        local closest = radius
        for i,unit in ipairs(nearby_enemy_units) do
            if not unit:IsMagicImmune() or pierce_spellimmunity then 
                -- First unit is the closest
                target = unit
                break
            end
        end
    end

    if not storm_cloud and target then
        -- If the target possesses a ready Linken's Sphere, do nothing
        if target:GetTeam() ~= caster:GetTeam() then
            if target:TriggerSpellAbsorb(ability) then
                return nil
            end
        end
    end

    -- If we still dont have a target we search for nearby creeps
    if target == nil then
        local nearby_enemy_units = FindUnitsInRadius(
            caster:GetTeamNumber(), 
            target_point, 
            nil, 
            spread_aoe, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            ability:GetAbilityTargetType(),
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )

        for i,unit in ipairs(nearby_enemy_units) do
            -- First unit is the closest
            target = unit
            break
        end
    end

    --local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, target, caster)
    --local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, target)
    --particles/econ/items/zeus/arcana_chariot/zuus_arcana_bolt_light.vpcf
    local particle = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning.vpcf", PATTACH_WORLDORIGIN, target)
    if target == nil then 
        -- Renders the particle on the ground target
        ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
        ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, z_pos))
        ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
    elseif target:IsMagicImmune() == false or pierce_spellimmunity then  
        target_point = target:GetAbsOrigin()
        ParticleManager:SetParticleControl(particle, 0, Vector(target_point.x, target_point.y, target_point.z))
        ParticleManager:SetParticleControl(particle, 1, Vector(target_point.x, target_point.y, z_pos))
        ParticleManager:SetParticleControl(particle, 2, Vector(target_point.x, target_point.y, target_point.z))
    end

    -- Add dummy to provide us with truesight aura
    local dummy_unit = CreateUnitByName("npc_dummy_unit", Vector(target_point.x, target_point.y, 0), false, nil, nil, caster:GetTeam())
    local true_sight = dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_true_sight", {duration = sight_duration})
    true_sight:SetStackCount(true_sight_radius)
    dummy_unit:SetDayTimeVisionRange(sight_radius_day)
    dummy_unit:SetNightTimeVisionRange(sight_radius_night)

    dummy_unit:AddNewModifier(caster, ability, "modifier_lightning_bolt", {})
    dummy_unit:AddNewModifier(caster, nil, "modifier_kill", {duration = sight_duration + 1}) --built-in modifier: remove dummy after duration
    --dummy_unit:AddNewModifier(caster, nil, "modifier_kill", {duration = sight_duration + 1})

    -- if they chose chain lightning, add that to the spell
    if caster:HasTalent("talent_chain_lightning") and (target == nil or not target:TriggerSpellAbsorb(ability))  then
        local cast_origin = caster
        if storm_cloud then
            cast_origin = storm_cloud
        end
        local head_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(head_particle, 0, cast_origin, PATTACH_POINT_FOLLOW, "attach_attack1", cast_origin:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(head_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		-- No reason for this CP besides that I like colours
		ParticleManager:SetParticleControl(head_particle, 62, Vector(2, 0, 2))

		ParticleManager:ReleaseParticleIndex(head_particle)
		
		caster:AddNewModifier(caster, ability, "modifier_talent_chain_lightning", {
			starting_unit_entindex	= target:entindex()
		})
    end

    if target ~= nil and target:GetTeam() ~= caster:GetTeam() then
            
        target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration * (1 - target:GetStatusResistance())})

        local damage_table 			= {}
        damage_table.attacker 		= caster
        damage_table.ability 		= ability
        damage_table.damage_type 	= ability:GetAbilityDamageType() 
        damage_table.damage			= ability:GetAbilityDamage()
        damage_table.victim 		= target

        -- Cannot deal magic dmg to immune... change to pure
        if pierce_spellimmunity then
            damage_table.damage_type = DAMAGE_TYPE_PURE
        end

        ApplyDamage(damage_table)
    end
    ParticleManager:ReleaseParticleIndex( particle )
end