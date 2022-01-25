ability_thunder_clap = ability_thunder_clap or class({})

LinkLuaModifier( "modifier_erect_wall_thinker", "scripts/vscripts/heroes/gilgamesh/modifier_erect_wall_thinker.lua", LUA_MODIFIER_MOTION_NONE )


function ability_thunder_clap:OnSpellStart()
    if not IsServer() then return end

    local caster    = self:GetCaster()
	--local point     = self:GetCursorPosition()

    local damage        = self:GetAbilityDamage()
	--local distance      = self:GetCastRange( point, caster )
	local duration      = self:GetSpecialValueFor("block_duration")
	local radius        = self:GetSpecialValueFor("radius")
	--local slow_duration = self:GetSpecialValueFor("slow_duration")

    self:MakeBlockers(caster)

    -- -- get list of affected enemies by the slow/damage
	-- local enemies = FindUnitsInRadius (
	-- 	self:GetCaster():GetTeamNumber(),
	-- 	self:GetCaster():GetOrigin(),
	-- 	nil,
	-- 	radius,
	-- 	DOTA_UNIT_TARGET_TEAM_ENEMY,
	-- 	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	-- 	DOTA_UNIT_TARGET_FLAG_NONE,
	-- 	FIND_ANY_ORDER,
	-- 	false
	-- )

	-- -- Do for each affected enemies
	-- for _,enemy in pairs(enemies) do
	-- 	-- Apply damage
	-- 	local damage = {
	-- 		victim = enemy,
	-- 		attacker = self:GetCaster(),
	-- 		damage = damage,
	-- 		damage_type = DAMAGE_TYPE_MAGICAL,
	-- 		ability = self
	-- 	}
	-- 	ApplyDamage( damage )

	-- 	-- Add slow modifier
	-- 	enemy:AddNewModifier(
	-- 		self:GetCaster(),
	-- 		self,
	-- 		"modifier_thunder_clap_debuff",
	-- 		{ duration = slow_duration }
	-- 	)
	-- end

	-- Play effects
	self:PlayEffects()
end

-- function ability_thunder_clap:PlayEffects( start_pos, end_pos, duration )
-- 	-- Get Resources
-- 	local particle_cast = "particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf"
-- 	local sound_cast = "Hero_EarthShaker.Fissure"

-- 	-- generate data
-- 	local caster = self:GetCaster()

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, caster )
-- 	--local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, caster )
-- 	ParticleManager:SetParticleControl( effect_cast, 0, start_pos )
-- 	ParticleManager:SetParticleControl( effect_cast, 1, end_pos )
-- 	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( start_pos, sound_cast, caster )
-- 	EmitSoundOnLocationWithCaster( end_pos, sound_cast, caster )
-- end

function ability_thunder_clap:PlayEffects()
	-- get resources
	local sound_cast = "Hero_Ursa.Earthshock"
	local particle_cast = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"

	-- get data
	local slow_radius = self:GetSpecialValueFor("radius")

	-- play particles
	 local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	--local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(slow_radius/2, slow_radius/2, slow_radius/2) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sounds
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function ability_thunder_clap:MakeBlockers_old(caster)
    local block_width = 24
	local block_delta = 8.25

    -- Create blocker along path
	--local block_spacing = (block_delta+2*block_width)
	local blocks = 8 --distance/block_spacing
	--local block_pos = caster:GetHullRadius() + block_delta + block_width
	--local start_pos = caster:GetOrigin() + direction*block_pos

	for i=1,blocks do
        local progress = i/blocks
        local theta = -2 * math.pi * progress
		local x =  math.sin( theta ) * block_width * 0.5
		local y = -math.cos( theta ) * block_delta * 0.5
        local block_vec = Vector(caster:GetAbsOrigin().x + x, caster:GetAbsOrigin().y + y, caster:GetAbsOrigin().z)
		--local block_vec = caster:GetOrigin() + direction*block_pos
        local blocker_unit = CreateUnitByName("npc_avalore_thunder_clap_blocker", block_vec, false, nil, nil, caster:GetTeam())
		--local blocker = CreateModifierThinker(
        -- local blocker = blocker_unit:AddNewModifier(
		-- 	caster, -- player source
		-- 	self, -- ability source
		-- 	"modifier_erect_wall_thinker", -- modifier name
		-- 	{ duration = duration } -- kv
        -- )
			--block_vec,
			--caster:GetTeamNumber(),
			--true
		--)
		--blocker:SetHullRadius( block_width )
		--block_pos = block_pos + block_spacing
	end
end

function ability_thunder_clap:MakeBlockers(caster)
    local block_width = 24
	local block_delta = 8.25
    local blocks = 8

    local radius = self:GetSpecialValueFor("radius")
    local caster_loc = caster:GetAbsOrigin()
    local caster_facing = caster:GetForwardVector()

    -- we're going to spawn a semi-circle, so we want to start on direct left/right of the caster
    -- then iteratively move in a semi-circle spawning rocks/blockers
    --local vX = caster_loc.x + caster_facing.x * radius
    -- local curr_block_vec = Vector(  caster_loc.x + caster_facing.x * radius,
    --                                 caster_loc.y,
    --                                 caster_loc.z)

    local curr_block_vec = GetGroundPosition(caster_loc + Vector(0, radius, 0), nil)

    for i=1,blocks do
        local blocker_unit = CreateUnitByName("npc_avalore_thunder_clap_blocker", curr_block_vec, false, nil, nil, caster:GetTeam())
        curr_block_vec		= RotatePosition(caster_loc, QAngle(0, 180 / blocks, 0), curr_block_vec)
    end
end