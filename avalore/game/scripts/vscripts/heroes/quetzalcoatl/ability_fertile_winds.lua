require("references")

ability_fertile_winds = ability_fertile_winds or class({})

LinkLuaModifier( "modifier_fertile_winds_helper", "scripts/vscripts/heroes/quetzalcoatl/modifier_fertile_winds_helper", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fertile_winds_heal", "scripts/vscripts/heroes/quetzalcoatl/modifier_fertile_winds_heal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_unselectable", MODIFIER_UNSELECTABLE, LUA_MODIFIER_MOTION_NONE )

function ability_fertile_winds:OnSpellStart(kv)
    if not IsServer() then return end

    local caster        = self:GetCaster()
	local target_point  = self:GetCursorPosition()

    local dashLength	= self:GetSpecialValueFor("dash_length")
    local dashWidth		= self:GetSpecialValueFor("dash_width")
    local dashDuration	= self:GetSpecialValueFor("dash_duration")
    local healRadius    = self:GetSpecialValueFor("heal_radius")
    local treeDuration  = self:GetSpecialValueFor("tree_duration")

    caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)

    --local modifierCasterName	= kv.modifier_caster_name

    -- track duration of flight/dive with a modifier that lasts that length of time
    local dummy_modifier	= "modifier_fertile_winds_helper"
	caster:AddNewModifier(caster, self, dummy_modifier, { duration = dashDuration })

    local direction = (target_point - caster:GetAbsOrigin()):Normalized()
	caster:SetForwardVector(direction)

    local casterOrigin	= caster:GetAbsOrigin()
	local casterAngles	= caster:GetAngles()
	local forwardDir	= caster:GetForwardVector()
	local rightDir		= caster:GetRightVector()

    local ellipseCenter	= casterOrigin + forwardDir * ( dashLength / 2 )

    local startTime = GameRules:GetGameTime()
    
    local pfx = ParticleManager:CreateParticle( "particles/econ/items/enchantress/enchantress_2021_immortal/enchantress_2021_immortal_ground_plants_flowers_b.vpcf", PATTACH_WORLDORIGIN, nil )
    local pfx2 = ParticleManager:CreateParticle("particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient_ground_tornado_pnt.vpcf", PATTACH_WORLDORIGIN, nil )

    self.tree_spawn_counter = 0
    self.heal_tree_counter = 3

    caster:SetContextThink( DoUniqueString("updateFertileWinds"), function ( )
        ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin() + caster:GetRightVector() * 32 )
        ParticleManager:SetParticleControl(pfx2, 0, caster:GetAbsOrigin() + caster:GetRightVector() * 32 )

		local elapsedTime = GameRules:GetGameTime() - startTime
		local progress = elapsedTime / dashDuration
        self.progress = progress

        if self.tree_spawn_counter > 0 then
            self.tree_spawn_counter = self.tree_spawn_counter - 1
        end

        -- TODO: spawn trees based on distance traveled rather than time interval since they'll bunch up
        --       at the tip of the ellipse
        if elapsedTime > 0.2 and elapsedTime < (dashDuration - 0.2) and self.tree_spawn_counter == 0 then
            local spawn_location = caster:GetAbsOrigin() + caster:GetRightVector() * 32
            --local tree = CreateTempTreeWithModel(caster:GetAbsOrigin() + caster:GetRightVector() * 32, treeDuration, "models/props_tree/dire_tree005.vmdl")
            CreateTempTreeWithModel(spawn_location, treeDuration, "models/props_tree/dire_tree005.vmdl")
            self.tree_spawn_counter = 3
            if self.heal_tree_counter == 0 then
                local unit = CreateUnitByName('npc_dummy_unit', spawn_location, false, caster, caster, caster:GetTeamNumber())
                unit:AddNewModifier(caster, self, "modifier_fertile_winds_heal", {duration = treeDuration })
                unit:AddNewModifier(caster, self, "modifier_unselectable", {duration = treeDuration })
                --tree:AddNewModifier(caster, self, "modifier_fertile_winds_heal", nil)
                self.heal_tree_counter = 3
            else
                self.heal_tree_counter = self.heal_tree_counter - 1
            end
        end

        -- Check the Debuff that can interrupt spell
		-- if imba_phoenix_check_for_canceled( caster ) then
		-- 	caster:RemoveModifierByName("modifier_imba_phoenix_icarus_dive_dash_dummy")
		-- end

		-- check for interrupted
		if not caster:HasModifier( dummy_modifier ) then
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
            ParticleManager:DestroyParticle(pfx2, false)
			ParticleManager:ReleaseParticleIndex(pfx2)
			return nil
		end

		-- Calculate potision
		local theta = -2 * math.pi * progress
		local x =  math.sin( theta ) * dashWidth * 0.5
		local y = -math.cos( theta ) * dashLength * 0.5

		local pos = ellipseCenter + rightDir * x + forwardDir * y
		local yaw = casterAngles.y + 90 + progress * -360  

		pos = GetGroundPosition( pos, caster )
		caster:SetAbsOrigin( pos )
		caster:SetAngles( casterAngles.x, yaw, casterAngles.z )

		return 0.03
	end, 0 )

    -- Swap sub ability
	-- local sub_ability_name	= "ability_fertile_winds_cancel"
	-- local main_ability_name	= ability:GetAbilityName()
	-- caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
end

function ability_fertile_winds:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	local heal = self:GetSpecialValueFor("heal_per_second")
	if target then
        target:Heal( heal, caster )
		--target:Heal( heal, self, caster )
    end
end