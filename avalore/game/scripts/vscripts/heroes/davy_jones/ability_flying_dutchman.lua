require("references")
require(REQ_LIB_TIMERS)

ability_flying_dutchman = class({})

LinkLuaModifier("modifier_flying_dutchman", "heroes/davy_jones/ability_flying_dutchman.lua", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_exorcism_spirit", )

function ability_flying_dutchman:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	--local ability = self:GetAbility()

	-- load data
	local duration 	= self:GetDuration()
	local delay_between_spirits = self:GetSpecialValueFor( "delay_between_spirits")

	-- get initial amount of spirits to dispatch based on number souls acquired
	--local ability_lost_souls = caster:FindAbilityByName( "ability_lost_souls" )
	local modifier_lost_souls = caster:FindModifierByName("modifier_lost_souls")
	local spirits = 0
	--if ability_lost_souls and ability_lost_souls:GetLevel() > 0 then
	if modifier_lost_souls then
		spirits = modifier_lost_souls:GetStackCount()
		--spirits = ability_lost_souls:GetStackCount()
	end

	-- Initialize the table to keep track of all spirits
	-- self.spirits = {}
	-- print("Spawning "..spirits.." spirits")
	-- for i=1,spirits do
	-- 	Timers:CreateTimer(i * delay_between_spirits, function()
	-- 		local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

	-- 		-- The modifier takes care of the physics and logic
	-- 		--self:ApplyDataDrivenModifier(caster, unit, "modifier_exorcism_spirit", {})
			
	-- 		-- Add the spawned unit to the table
	-- 		table.insert(self.spirits, unit)

	-- 		-- Initialize the number of hits, to define the heal done after the ability ends
	-- 		unit.numberOfHits = 0

	-- 		-- Double check to kill the units, remove this later
	-- 		Timers:CreateTimer(duration+10, function() if unit and IsValidEntity(unit) then unit:RemoveSelf() end end)
	-- 	end)
	-- end

	-- add modifier
	caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_flying_dutchman", -- modifier name
		{   duration = duration,
		    spawn_interval = delay_between_spirits,
		    spirits = spirits } -- kv
	)
end

-- ==================
-- MODIFIER => Caster
-- ==================

modifier_flying_dutchman = class({})

-- Classifications
function modifier_flying_dutchman:IsHidden()
	return false
end

function modifier_flying_dutchman:IsDebuff()
	return false
end

function modifier_flying_dutchman:IsPurgable()
	return false
end

function modifier_flying_dutchman:OnCreated(kv)
	self.duration = kv.duration
	self.spawn_interval = kv.spawn_interval
	self.spirits_max = kv.spirits
	self.spirits_dispatched = 0
	self.unit_model_name = "models/creeps/neutral_creeps/n_creep_ghost_b/n_creep_ghost_frost.vmdl"

	if IsServer() then
		self:StartIntervalThink( self.spawn_interval )
		self:OnIntervalThink()
	end
end

function modifier_flying_dutchman:OnIntervalThink()

	if self.spirits_max ~= self.spirits_dispatched then
		local unit = CreateUnitByName(self.unit_model_name, self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())

		-- The modifier takes care of the physics and logic
		self:ApplyDataDrivenModifier(self:GetCaster(), unit, "modifier_lost_soul_ghost", {})	
		--ApplyDataDrivenModifier(handle hCaster, handle hTarget, string pszModifierName, handle hModifierTable)
		--self:ApplyDataDrivenModifier(self:GetCaster(), unit, "modifier_exorcism_spirit", {})	
		
		-- Add the spawned unit to the table
		table.insert(self.spirits, unit)

		self.spirits_dispatched = self.spirits_dispatched + 1
	end
end

-- ==================
-- MODIFIER => Ghosts
-- ==================

modifier_lost_soul_ghost = class({})

function modifier_lost_soul_ghost:IsHidden()
	return true
end

function modifier_lost_soul_ghost:IsPurgable()
	return false
end

function modifier_lost_soul_ghost:OnCreated( kv )
	local damage = 10 --self:GetAbility():GetSpecialValueFor( "attack_damage" )
	self.interval = 2--self:GetAbility():GetSpecialValueFor( "attack_interval" )
	self.radius = 500--self:GetAbility():GetSpecialValueFor( "attack_radius" )

	if not IsServer() then return end

	self.info = {
		-- Target = target,
		Source = self:GetParent(),
		Ability = self:GetAbility(),	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
		-- bIsAttack = false,                                -- Optional

		ExtraData = {
			damage = damage,
		}
	}

	-- Start interval
	self:StartIntervalThink( self.interval )

	-- play effects
	--self:PlayEffects()

end

function modifier_lost_soul_ghost:OnIntervalThink()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- create projectile effect
		local effect = self:PlayEffects1( enemy, self.info.iMoveSpeed )

		-- launch attack
		self.info.Target = enemy
		self.info.ExtraData.effect = effect

		ProjectileManager:CreateTrackingProjectile( self.info )

		-- play effects
		local sound_cast = "Hero_DarkWillow.WillOWisp.Damage"
		EmitSoundOn( sound_cast, self:GetParent() )

		-- only on first unit
		break
	end
end