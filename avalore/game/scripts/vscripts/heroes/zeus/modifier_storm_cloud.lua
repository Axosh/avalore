require("scripts/vscripts/heroes/zeus/ability_lightning_bolt")
modifier_storm_cloud = class({})

STORM_CLOUD_PARTICLE_KEY = 1

function modifier_storm_cloud:IsHidden() return true end

function modifier_storm_cloud:CheckState()
	return {    [MODIFIER_STATE_FLYING] = true,
                [MODIFIER_STATE_DISARMED] = true,
                [MODIFIER_STATE_MUTED] = true
            }
end

function modifier_storm_cloud:GetActivityTranslationModifiers()
	return "hunter_night"
end

function modifier_storm_cloud:GetModifierMoveSpeed_AbsoluteMin()
    return 400
end

function modifier_storm_cloud:OnCreated(keys)
	if IsServer() then
		self.ability 				= self
		self.cloud_radius 			= keys.cloud_radius
		self.cloud_bolt_interval 	= keys.cloud_bolt_interval
		self.lightning_bolt 		= self:GetCaster():FindAbilityByName("ability_lightning_bolt")
		local target_point 			= GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetParent())
		
		self.original_z = target_point.z
		self:SetStackCount(self.original_z)
		
		-- Initialize counter to equal that of the interval so Nimbus can immediately strike targets upon spawn
		self.counter = self.cloud_bolt_interval
        self.cloud_counter = 0

        local particles = {}
        --particles[0] = "particles/units/heroes/hero_zeus/zeus_cloud_overhead.vpcf" -- NOTE: doesn't move
        --particles[1] = "particles/units/heroes/hero_zeus/zeus_cloud_overhead_core.vpcf" -- NOTE: doesn't move
        particles[0] = "particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_manaburn_impact_lightning_gold.vpcf"
        --particles[1] = "particles/econ/courier/courier_ti10/courier_flying_dire_ti10_cloud.vpcf"
        --particles[1] = "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff_cloud.vpcf"
        particles[STORM_CLOUD_PARTICLE_KEY] = "particles/econ/items/monkey_king/arcana/monkey_arcana_cloud.vpcf"
        particles[2] = "particles/units/heroes/hero_zeus/zeus_cloud_ground_edge.vpcf"
        particles[3] = "particles/units/heroes/hero_zeus/zeus_cloud_ground_glow.vpcf"
        particles[4] = "particles/units/heroes/hero_zeus/zeus_cloud_ground_haze.vpcf"
        particles[5] = "particles/units/heroes/hero_zeus/zeus_cloud_ground_sparks.vpcf"
		-- if self:GetCaster():HasTalent("talent_rainstorm") then 
		-- 	particles[6] = "particles/units/heroes/hero_slardar/slardar_amp_damage_rain.vpcf"
		-- end
        --particles[6] = "particles/econ/events/spring_2021/radiance_owner_spring_2021_rings_proj.vpcf"
        --particles[6] = "particles/econ/events/spring_2021/cyclone_spring2021_ground_b.vpcf"

        self.storm_cloud_particle = {}

        for k,particle in pairs(particles) do
            self.storm_cloud_particle[k] = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            -- Position of ground effect
            ParticleManager:SetParticleControl(self.storm_cloud_particle[k], 0, Vector(target_point.x, target_point.y, 450))
            -- Radius of ground effect
            ParticleManager:SetParticleControl(self.storm_cloud_particle[k], 1, Vector(self.cloud_radius, 0, 0))
            -- Position of cloud 
            ParticleManager:SetParticleControl(self.storm_cloud_particle[k], 2, Vector(target_point.x, target_point.y, target_point.z + 450))	
        end

		if self:GetCaster():HasTalent("talent_rainstorm") then 
			-- particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf
			--local rain = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_amp_damage_rain.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
			-- see: https://github.com/Chiayue/mengshahe/blob/814000be300607736c2ada9bca321e82ded19df4/scripts/vscripts/ability/abilities_lua/modifier/modifier_active_thunder_storm_lua.lua
			-- local rain = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_rain_storm.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetParent())
			local rain = ParticleManager:CreateParticle(
							"particles/units/heroes/hero_razor/razor_rain_storm.vpcf", 
							PATTACH_CUSTOMORIGIN_FOLLOW, 
							self:GetParent())
			ParticleManager:SetParticleControl(self.storm_cloud_particle[k], 0, Vector(target_point.x, target_point.y, 450))
			-- ParticleManager:SetParticleControlEnt( rain, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(target_point.x, target_point.y, 0), true )
			-- self:AddParticle( rain, false, false, -1, false, true )
			--ParticleManager:SetParticleControl(rain, 0, Vector(target_point.x, target_point.y, -450))

			-- ParticleManager:SetParticleControl(rain, 0, target_point)
			-- self:AddParticle( rain, false, false, 15, false, false )
			-- ParticleManager:SetParticleControlEnt(rain, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			-- ParticleManager:SetParticleControlEnt(rain, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

			-- ParticleManager:SetParticleControlEnt(rain, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(target_point.x, target_point.y, target_point.z - 450), true)
			-- ParticleManager:SetParticleControlEnt(rain, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(target_point.x, target_point.y, target_point.z - 450), true)

			-- ParticleManager:SetParticleControl(rain, 0, Vector(target_point.x, target_point.y, 450))
            -- -- Radius of ground effect
            -- ParticleManager:SetParticleControl(rain, 1, Vector(self.cloud_radius, 0, 0))
            -- -- Position of cloud 
            -- ParticleManager:SetParticleControl(rain, 2, self:GetParent():GetAbsOrigin())
			-- ParticleManager:SetParticleControl(rain, 62, self:GetParent():GetAbsOrigin());
			self.storm_cloud_particle[6] = rain;
		end

		-- Create nimbus cloud particle
		--self.zuus_nimbus_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster())
        --self.zuus_nimbus_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zeus/zeus_cloud.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		-- Position of ground effect
		--ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 0, Vector(target_point.x, target_point.y, 450))
		-- Radius of ground effect
		--ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 1, Vector(self.cloud_radius, 0, 0))
		-- Position of cloud 
		--ParticleManager:SetParticleControl(self.zuus_nimbus_particle, 2, Vector(target_point.x, target_point.y, target_point.z + 450))	

        -- find other particles associated and re-create them
        --ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("zeus_cloud_ground_light", self:GetParent()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_storm_cloud:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function modifier_storm_cloud:GetVisualZDelta()
	return 450
end

function modifier_storm_cloud:OnIntervalThink()
	if IsServer() then
		if self.lightning_bolt:GetLevel() > 0 and self.counter >= self.cloud_bolt_interval then
			local nearby_enemy_units = FindUnitsInRadius(
				self:GetCaster():GetTeamNumber(), 
				self:GetParent():GetAbsOrigin(), 
				nil, 
				self.cloud_radius, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				self.lightning_bolt:GetAbilityTargetType(),
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_CLOSEST,
				false
			)

			for _,unit in pairs(nearby_enemy_units) do
				if unit:IsAlive() then
					ability_lightning_bolt:LightningBolt(self:GetCaster(), self.lightning_bolt, unit, unit:GetAbsOrigin(), self:GetParent())
					-- Abort when we find something to hit
					self.counter = 0
					break
				end
			end            
		end

        if self.cloud_counter > 5.0 then
            --  refresh the storm cloud particle because it expires every 5sec or so
            local temp_cloud_particle = ParticleManager:CreateParticle(ParticleManager:GetParticleReplacement("particles/econ/items/monkey_king/arcana/monkey_arcana_cloud.vpcf", self:GetParent()), PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:DestroyParticle(self.storm_cloud_particle[STORM_CLOUD_PARTICLE_KEY], false)
            self.storm_cloud_particle[STORM_CLOUD_PARTICLE_KEY] = temp_cloud_particle
            self.cloud_counter = 0
        end
		
        self.cloud_counter = self.cloud_counter + FrameTime()
		self.counter = self.counter + FrameTime()
	end
end

function modifier_storm_cloud:OnAttacked(params)
	if params.target == self:GetParent() then
		if params.attacker:IsRealHero() then
			if params.attacker:IsRangedAttacker() then
				-- print("Ranged attack!", self:GetParent():GetHealth() - self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("ranged_hero_attack"))
				self:GetParent():SetHealth(self:GetParent():GetHealth() - self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("ranged_hero_attack"))
			else
				-- print("Melee Attack!", self:GetParent():GetHealth() - (self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("melee_hero_attack")))
				self:GetParent():SetHealth(self:GetParent():GetHealth() - (self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("melee_hero_attack")))
			end
		else
			-- print("Non-hero!", self:GetParent():GetHealth() - (self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("non_hero_attack")))
			self:GetParent():SetHealth(self:GetParent():GetHealth() - (self:GetParent():GetMaxHealth() / self:GetAbility():GetSpecialValueFor("non_hero_attack")))
		end
	end
end

function modifier_storm_cloud:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_storm_cloud:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_storm_cloud:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_storm_cloud:OnRemoved()
	if IsServer() then
		-- Cleanup particle
        for k,particle in pairs(self.storm_cloud_particle) do
		    ParticleManager:DestroyParticle(self.storm_cloud_particle[k], false)
        end
		local caster = self:GetCaster()
		local nimbusRemaining = false

		-- -- Return Zeus to ground if it's the current cloud that ended
		-- if caster:HasModifier("modifier_imba_zuus_nimbus_z") then
		-- 	caster:RemoveModifierByName("modifier_imba_zuus_nimbus_z")
		-- 	FindClearSpaceForUnit(caster, self:GetCaster():GetAbsOrigin(), false)
		-- end
		
		-- Check to see if there are any active nimbuses on the map, and set variable to true if there is
		for _, nimbus in pairs(Entities:FindAllByName("avalore_unit_storm_cloud")) do
			if nimbus:IsAlive() then
				nimbusRemaining = true
				break
			end
		end
		
		-- If there are no active nimbuses on the map anymore...
		-- if not nimbusRemaining then
		-- 	-- ...and the owner has both relevant abilities...
		-- 	if caster:HasAbility("imba_zuus_leave_nimbus") and caster:HasAbility("imba_zuus_nimbus_zap") then
		-- 		-- ...and the "Descend" skill is visible on the skills menu...
		-- 		if not caster:FindAbilityByName("imba_zuus_leave_nimbus"):IsHidden() then
		-- 			caster:SwapAbilities("imba_zuus_leave_nimbus", "imba_zuus_nimbus_zap", false, true)
		-- 		end
		-- 		self:GetCaster():FindAbilityByName("imba_zuus_nimbus_zap"):SetActivated(false)
		-- 	end
		-- end
	end
end