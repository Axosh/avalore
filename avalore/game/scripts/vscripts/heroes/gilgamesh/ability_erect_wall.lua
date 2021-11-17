ability_erect_wall = ability_erect_wall or class({})

LinkLuaModifier( "modifier_erect_wall_thinker", "scripts/vscripts/heroes/gilgamesh/modifier_erect_wall_thinker.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_avalore_stunned", "modifiers/modifier_avalore_stunned", LUA_MODIFIER_MOTION_NONE )

function ability_erect_wall:OnSpellStart()
    if not IsServer() then return end

    local caster         = self:GetCaster()
    local vector_targets = self:GetVectorTargetPosition()
	--local point = self:GetCursorPosition()
	

    local duration      = self:GetSpecialValueFor("duration")
    local radius        = self:GetSpecialValueFor("radius")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
	--local distance 		= self:GetCastRange()
	local distance 		= self:GetSpecialValueFor("width")

    local block_width   = 24
    local block_delta   = 8.25

    -- wall vector
    --local direction = point-vector_targets.init_pos
	local direction = vector_targets.direction --vector_targets.end_pos - vector_targets.init_pos
	direction.z = 0
	direction = direction:Normalized()
	local wall_vector = direction * distance

	-- Create blocker along path
	local block_spacing = (block_delta+2*block_width)
	local blocks = distance/block_spacing
	local block_pos = caster:GetHullRadius() + block_delta + block_width
	local start_pos = caster:GetOrigin() + direction*block_pos

	for i=1,blocks do
		local block_vec = caster:GetOrigin() + direction*block_pos
		local blocker = CreateModifierThinker(
												caster, -- player source
												self, -- ability source
												"modifier_erect_wall_thinker", -- modifier name
												{ duration = duration }, -- kv
												block_vec,
												caster:GetTeamNumber(),
												true
											)
		blocker:SetHullRadius( block_width )
		block_pos = block_pos + block_spacing
	end

	-- find units in line
	local end_pos = start_pos + wall_vector
	local units = FindUnitsInLine(
		caster:GetTeamNumber(),
		start_pos,
		end_pos,
		-- caster:GetOrigin() + direction*caster:GetHullRadius(),
		-- caster:GetOrigin() + direction*caster:GetHullRadius() + wall_vector,
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0
	)

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}

	-- apply damage, shove and stun
	for _,unit in pairs(units) do
		-- shove
		FindClearSpaceForUnit( unit, unit:GetOrigin(), true )

		if unit:GetTeamNumber()~=caster:GetTeamNumber() then
			-- damage
			damageTable.victim = unit
			ApplyDamage(damageTable)

			-- stun
			unit:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"modifier_avalore_stunned", -- modifier name
				{ duration = stun_duration } -- kv
			)
		end
	end

	-- Effects
	self:PlayEffects( start_pos, end_pos, duration )
end


function ability_erect_wall:PlayEffects( start_pos, end_pos, duration )
	-- Get Resources
	local particle_cast = "particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_gravelmaw.vpcf"
	local sound_cast = "Hero_EarthShaker.Fissure"

	-- generate data
	local caster = self:GetCaster()

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
	--local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( effect_cast, 0, start_pos )
	ParticleManager:SetParticleControl( effect_cast, 1, end_pos )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( start_pos, sound_cast, caster )
	EmitSoundOnLocationWithCaster( end_pos, sound_cast, caster )
end