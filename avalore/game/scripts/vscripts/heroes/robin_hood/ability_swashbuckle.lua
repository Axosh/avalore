--require("scripts/vscripts/modifiers/modifier_knockback")
ability_swashbuckle = ability_swashbuckle or class({})

LinkLuaModifier( "modifier_knockback_avalore", "scripts/vscripts/modifiers/modifier_knockback_avalore", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier( "modifier_swashbuckle", "heroes/robin_hood/modifier_swashbuckle.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_disarm", "heroes/robin_hood/modifier_talent_disarm.lua", LUA_MODIFIER_MOTION_NONE )

-- ==================================================
-- Ability Phase Start
-- ==================================================
function ability_swashbuckle:OnAbilityPhaseInterrupted()

end
function ability_swashbuckle:OnAbilityPhaseStart()
	-- Vector targeting
	if not self:CheckVectorTargetPosition() then return false end
	return true -- if success
end

-- ==================================================
-- Ability Start
-- ==================================================
function ability_swashbuckle:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local targets = self:GetVectorTargetPosition()

	-- load data
	local speed = self:GetSpecialValueFor( "dash_speed" )
	local direction = targets.direction

	local vector = (targets.init_pos-caster:GetOrigin())
	local dist = vector:Length2D()
	vector.z = 0
	vector = vector:Normalized()

	-- Facing
	caster:SetForwardVector( direction )

	-- Play effects
	local effects = self:PlayEffects()

	-- knockback
	local knockback = caster:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_knockback_avalore", -- modifier name
		{
			direction_x = vector.x,
			direction_y = vector.y,
			distance = dist,
			duration = dist/speed,
			IsStun = true,
			IsFlail = false,
		} -- kv
	)
    --knockback:Test()
    --print("[ability_swashbuckle] Knockback made? " .. knockback:GetName())
	local callback = function( bInterrupted )
        --print("[ability_swashbuckle] Creating Callback Function")
		-- stop effects
		ParticleManager:DestroyParticle( effects, false )
		ParticleManager:ReleaseParticleIndex( effects )

        --print("[ability_swashbuckle] Cleaned Up Particles")

		if bInterrupted then return end

		-- add modifier
		caster:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_swashbuckle", -- modifier name
			{
				dir_x = direction.x,
				dir_y = direction.y,
				duration = 3, -- max duration
			} -- kv
		)
		
	end
    --print("[ability_swashbuckle] Callback? " .. callback)
    --print("[ability_swashbuckle] Knockback still exists? " .. knockback:GetName())
	knockback:SetEndCallback( callback )
end

function ability_swashbuckle:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
	local sound_cast = "Hero_Pangolier.Swashbuckle.Cast"
	local sound_layer = "Hero_Pangolier.Swashbuckle.Layer"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
	EmitSoundOn( sound_layer, self:GetCaster() )

	return effect_cast
end