ability_flora_and_fauna = ability_flora_and_fauna or class({})

LinkLuaModifier("modifier_rose_bush_debuff", "heroes/quetzalcoatl/modifier_rose_bush_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function ability_flora_and_fauna:OnSpellStart()
    -- Preventing projectiles getting stuck in one spot due to potential 0 length vector
    if self:GetCursorPosition() == self:GetCaster():GetAbsOrigin() then
        self:GetCaster():SetCursorPosition(self:GetCursorPosition() + self:GetCaster():GetForwardVector())
    end

	local travel_time = self:GetSpecialValueFor("travel_time") + self:GetCaster():FindTalentValue("talent_life_giver", "bonus_travel_time")

    local start_pos			= nil
	local bat_dummy		    = nil
	local projectile_table	= nil
	local projectileID		= nil

    for bats = 1, self:GetSpecialValueFor("count") do
		start_pos = self:GetCaster():GetAbsOrigin() + RandomVector(RandomInt(0, self:GetSpecialValueFor("spawn_radius")))
		
        local projectile_dummy_unit = CreateUnitByName("npc_bat_dummy_unit", start_pos, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        projectile_dummy_unit:SetForwardVector(self:GetCaster():GetForwardVector():Normalized())
        --projectile_dummy_unit:SetModel("models/props_wildlife/wildlife_bat001.vmdl")
        projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_unselectable", {duration = self:GetSpecialValueFor("travel_time") })
        projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {duration = self:GetSpecialValueFor("travel_time") })
        projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {duration = self:GetSpecialValueFor("travel_time") })

		bat_dummy = CreateModifierThinker(self:GetCaster(), self, nil, 
		{
			
		}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
		
		-- Let's not kill eardrums
		-- if bats == 1 then
		-- 	bat_dummy:EmitSound("Hero_Weaver.Swarm.Projectile")	
		-- end
	
		projectile_table = {
			Ability				= self,
			--EffectName			= "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm_bats.vpcf",
			-- "The beetles spawn within a 300 radius around of Weaver (random position) and move forward as a swarm."
			vSpawnOrigin		= start_pos,
			-- "The Swarm moves forward at a speed of 600, taking 5 seconds to reach max distance."
			-- Gonna add the 5 second as an AbilitySpecial which isn't a thing in vanilla
			fDistance			= (self:GetSpecialValueFor("speed") * travel_time) + self:GetCaster():GetCastRangeBonus(),
			fStartRadius		= self:GetSpecialValueFor("radius"),
			fEndRadius			= self:GetSpecialValueFor("radius"),
			Source				= self:GetCaster(),
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NO_INVIS,
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			fExpireTime 		= GameRules:GetGameTime() + 10.0,
			bDeleteOnHit		= false,
			vVelocity			= (self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("speed") * Vector(1, 1, 0),
			bProvidesVision		= true,
			-- "The beetles provide flying vision while traveling forwards and while attached to a unit."
			iVisionRadius 		= 321,
			iVisionTeamNumber 	= self:GetCaster():GetTeamNumber(),
			
			ExtraData			= 
			{
				bat_entindex	            = bat_dummy:entindex(),
                projectile_unit_entindex    = projectile_dummy_unit:entindex()
			}
		}
		
		projectileID = ProjectileManager:CreateLinearProjectile(projectile_table)
		
		bat_dummy.projectileID	= projectileID
	end
end

-- Make the travel sound follow the bettle
-- function imba_weaver_the_swarm:OnProjectileThink_ExtraData(location, data)
-- 	if data.bat_entindex and EntIndexToHScript(data.bat_entindex) and not EntIndexToHScript(data.beetle_entindex):IsNull() then
-- 		EntIndexToHScript(data.bat_entindex):SetAbsOrigin(location)
-- 	end
-- end

function ability_flora_and_fauna:OnProjectileThink_ExtraData(location, data)
	if not IsServer() then return end
	
	if data.projectile_unit_entindex and EntIndexToHScript(data.projectile_unit_entindex) then
		--if EntIndexToHScript(data.projectile_unit_entindex):IsAlive() then

        -- make sure the unit follows the curvature of the terrain rather than clipping through
        local unit = EntIndexToHScript(data.projectile_unit_entindex)
        local location_to_ground_level = GetGroundPosition(location, unit)
		unit:SetAbsOrigin(location_to_ground_level)
        --end
		-- else
		-- 	-- Destroy the vision particle early if the phantom is killed mid-air while moving towards target
		-- 	ParticleManager:DestroyParticle(data.phantoms_embrace_particle, false)
		-- 	ParticleManager:ReleaseParticleIndex(data.phantoms_embrace_particle)
		-- end
	end

	-- ChangeTrackingProjectileSpeed(arg1: handle, arg2: int): nil
end

function ability_flora_and_fauna:OnProjectileHit_ExtraData(target, location, data)

	local duration = self:GetSpecialValueFor("duration") + self:GetCaster():FindTalentValue("talent_life_giver", "bonus_duration")
    -- if they're hit by a bat and don't have the debuff, give it to them
	if target and not target:HasModifier("modifier_rose_bush_debuff") and data.bat_entindex and EntIndexToHScript(data.bat_entindex) and not EntIndexToHScript(data.bat_entindex):IsNull() then
		
		target:AddNewModifier(self:GetCaster(), self, "modifier_rose_bush_debuff",
		{
			duration 			= duration,
			damage				= self:GetSpecialValueFor("damage"),
			damage_type			= self:GetAbilityDamageType(),
			impact_num 			= 0 --tracks whether we splinter or not for the talent
			--beetle_entindex		= beetle:entindex()
		})
		
		if data.bat_entindex and EntIndexToHScript(data.bat_entindex) and EntIndexToHScript(data.bat_entindex).projectileID then
			ProjectileManager:DestroyLinearProjectile(EntIndexToHScript(data.bat_entindex).projectileID)
			EntIndexToHScript(data.bat_entindex):StopSound("Hero_Weaver.Swarm.Projectile")
			EntIndexToHScript(data.bat_entindex):RemoveSelf()
            EntIndexToHScript(data.projectile_unit_entindex):RemoveSelf()
		end

	elseif not target and data.bat_entindex and EntIndexToHScript(data.bat_entindex) and not EntIndexToHScript(data.bat_entindex):IsNull() then
		EntIndexToHScript(data.bat_entindex):StopSound("Hero_Weaver.Swarm.Projectile")
		EntIndexToHScript(data.bat_entindex):RemoveSelf()
        EntIndexToHScript(data.projectile_unit_entindex):RemoveSelf()
	end
end