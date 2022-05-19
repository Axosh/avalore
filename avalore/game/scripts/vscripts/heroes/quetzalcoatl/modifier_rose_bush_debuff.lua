modifier_rose_bush_debuff = class({})

function modifier_rose_bush_debuff:IsHidden() return false end
function modifier_rose_bush_debuff:IsDebuff() return true end
function modifier_rose_bush_debuff:IsStunDebuff() return false end
function modifier_rose_bush_debuff:IsPurgable() return true end
function modifier_rose_bush_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_rose_bush_debuff:GetTexture()
    return "quetzalcoatl/rose_bush_debuff"
end


function modifier_rose_bush_debuff:OnCreated( kv )

	if not IsServer() then return end
	-- references
	local duration = kv.duration
	local damage = kv.damage
	local interval = 0.5
	local impact_num = kv.impact_num

	-- set dps
	local instances = duration/interval
	local dps = damage/instances

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = dps,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}
	-- ApplyDamage(damageTable)

	-- if they have the talent, then send out more
	if self:GetCaster():HasTalent("talent_second_bloom") and impact_num < 1 then
		local start_pos			= GetGroundPosition(self:GetParent():GetAbsOrigin() + Vector(0, 10,  0), nil)
		local bat_dummy		    = nil
		local projectile_table	= nil
		local projectileID		= nil
		local num_bats 			= 8
		for bats=1,num_bats do
		
			local projectile_dummy_unit = CreateUnitByName("npc_bat_dummy_unit", start_pos, false, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
			--projectile_dummy_unit:SetForwardVector(self:GetCaster():GetForwardVector():Normalized())
			--projectile_dummy_unit:SetModel("models/props_wildlife/wildlife_bat001.vmdl")
			projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_unselectable", {duration = self:GetAbility():GetSpecialValueFor("travel_time") })
			projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {duration = self:GetAbility():GetSpecialValueFor("travel_time") })
			projectile_dummy_unit:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", {duration = self:GetAbility():GetSpecialValueFor("travel_time") })

			bat_dummy = CreateModifierThinker(self:GetCaster(), self, nil, 
			{
				
			}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)

			projectile_table = {
				Ability				= self,
				--EffectName			= "particles/units/heroes/hero_death_prophet/death_prophet_carrion_swarm_bats.vpcf",
				-- "The beetles spawn within a 300 radius around of Weaver (random position) and move forward as a swarm."
				vSpawnOrigin		= start_pos,
				-- "The Swarm moves forward at a speed of 600, taking 5 seconds to reach max distance."
				-- Gonna add the 5 second as an AbilitySpecial which isn't a thing in vanilla
				fDistance			= (self:GetAbility():GetSpecialValueFor("speed") * self:GetAbility():GetSpecialValueFor("travel_time")) + self:GetCaster():GetCastRangeBonus(),
				fStartRadius		= self:GetAbility():GetSpecialValueFor("radius"),
				fEndRadius			= self:GetAbility():GetSpecialValueFor("radius"),
				Source				= self:GetCaster(),
				bHasFrontalCone		= false,
				bReplaceExisting	= false,
				iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NO_INVIS,
				iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime 		= GameRules:GetGameTime() + 10.0,
				bDeleteOnHit		= false,
				vVelocity			= (self:GetParent():GetAbsOrigin()):Normalized() * self:GetAbility():GetSpecialValueFor("speed") * Vector(1, 1, 0),
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

		start_pos = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 360/num_bats), start_pos)
	end

	-- Start interval
	self:StartIntervalThink( interval )

	-- play effects
	local sount_cast1 = "Hero_DarkWillow.Bramble.Target"
	local sount_cast2 = "Hero_DarkWillow.Bramble.Target.Layer"
	EmitSoundOn( sount_cast1, self:GetParent() )
	EmitSoundOn( sount_cast2, self:GetParent() )
end

function modifier_rose_bush_debuff:OnRefresh( kv )
end

function modifier_rose_bush_debuff:OnRemoved()
end

function modifier_rose_bush_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_rose_bush_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_rose_bush_debuff:OnIntervalThink()
	-- apply damage
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_rose_bush_debuff:GetEffectName()
	return "particles/econ/items/dark_willow/dark_willow_chakram_immortal/dark_willow_chakram_immortal_bramble.vpcf"
end

function modifier_rose_bush_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


-- for talent
function modifier_rose_bush_debuff:OnProjectileThink_ExtraData(location, data)
	if not IsServer() then return end
	
	if data.projectile_unit_entindex and EntIndexToHScript(data.projectile_unit_entindex) then
        -- make sure the unit follows the curvature of the terrain rather than clipping through
        local unit = EntIndexToHScript(data.projectile_unit_entindex)
        local location_to_ground_level = GetGroundPosition(location, unit)
		unit:SetAbsOrigin(location_to_ground_level)
	end
end

function modifier_rose_bush_debuff:OnProjectileHit_ExtraData(target, location, data)
    -- if they're hit by a bat and don't have the debuff, give it to them
	if target and not target:HasModifier("modifier_rose_bush_debuff") and data.bat_entindex and EntIndexToHScript(data.bat_entindex) and not EntIndexToHScript(data.bat_entindex):IsNull() then
		
		target:AddNewModifier(self:GetCaster(), self, "modifier_rose_bush_debuff",
		{
			duration 			= self:GetAbility():GetSpecialValueFor("duration"),
			damage				= self:GetAbility():GetSpecialValueFor("damage"),
			damage_type			= self:GetAbility():GetAbilityDamageType(),
			impact_num 			= 1 --tracks whether we splinter or not for the talent
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