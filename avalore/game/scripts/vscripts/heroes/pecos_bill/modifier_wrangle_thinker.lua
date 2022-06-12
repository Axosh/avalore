modifier_wrangle_thinker = class({})

function modifier_wrangle_thinker:IsHidden() return false end
function modifier_wrangle_thinker:IsDebuff() return false end
function modifier_wrangle_thinker:IsStunDebuff() return false end
function modifier_wrangle_thinker:IsPurgable() return true end

function modifier_wrangle_thinker:OnCreated( kv )
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()

	-- references
	self.damage     = self:GetAbility():GetSpecialValueFor( "total_damage" )
	self.duration   = self:GetAbility():GetSpecialValueFor( "debuff_duration" )
	self.speed      = self:GetAbility():GetSpecialValueFor( "projectile_speed" )
	self.radius     = self:GetAbility():GetSpecialValueFor( "radius" ) + self:GetCaster():FindTalentValue("talent_drive", "bonus_aoe")

	if not IsServer() then return end

	-- print("Debug KV")
	-- if kv then
	-- 	PrintTable(kv)
	-- end

	PrintVector(self:GetParent():GetOrigin(), "Modifier Origin")

	self.location           = self:GetParent():GetOrigin() --kv.location --self:GetParent():GetOrigin()
	self.abilityDamageType  = self:GetAbility():GetAbilityDamageType()

	self:PlayEffects1()
end

function modifier_wrangle_thinker:OnRefresh( kv )
end

function modifier_wrangle_thinker:OnRemoved()
end


function modifier_wrangle_thinker:OnDestroy()
	if not IsServer() then return end

	PrintVector(self.location, "Destroy - Location")

	-- vision
	--AddFOWViewer( self.caster:GetTeamNumber(), self.location, self.radius, self.duration, false )

	-- find enemies
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #enemies<1 then
		self:PlayEffects2( false )
		return
	end

	-- -- find trees
	-- local trees = GridNav:GetAllTreesAroundPoint( self.location, self.radius, false )
	-- if #trees<1 then
	-- 	self:PlayEffects2( false )
	-- 	return
	-- end

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = self.damage,
		damage_type = self.abilityDamageType,
		ability = self.ability, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}
	
	-- match enemies with closest trees
	for _,enemy in pairs(enemies) do

		-- damage
		damageTable.victim = enemy
		ApplyDamage( damageTable )

		-- -- get closest tree
		-- local origin = enemy:GetOrigin()
		-- local mytree = trees[1]
		-- local mytreedist = (trees[1]:GetOrigin()-origin):Length2D()
		-- for _,tree in pairs(trees) do
		-- 	local treedist = (tree:GetOrigin()-origin):Length2D()
		-- 	if treedist<mytreedist then
		-- 		mytree = tree
		-- 		mytreedist = treedist
		-- 	end
		-- end

		enemy:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"modifier_wrangle_debuff", -- modifier name
			{
				duration = self.duration,
                center_x = self.location.x, -- can't pass object in, break into components
				center_y = self.location.y,
				center_z = self.location.z,
				--tree = mytree:entindex(),
			} -- kv
		)

	end

	-- play effects
	self:PlayEffects2( true )

	UTIL_Remove( self:GetParent() )
end

function modifier_wrangle_thinker:OnIntervalThink()
end

function modifier_wrangle_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Cast"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self.caster:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self:GetParent():GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.speed, 0, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- Create Sound
	EmitSoundOn( sound_cast, self.caster )
end

function modifier_wrangle_thinker:PlayEffects2( success )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_fail.vpcf"
	local sound_cast = "Hero_Hoodwink.Bushwhack.Cast"
	local sound_location = "Hero_Hoodwink.Bushwhack.Impact"
	if success then
		particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf"
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.location )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	StopSoundOn( sound_cast, self.caster )
	EmitSoundOnLocationWithCaster( self.location, sound_location, self.caster )


	-- show return snake particles
	--particle_cast = "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf"
	-- particle_cast =  "particles/econ/items/medusa/medusa_ti10_immortal_tail/medusa_ti10_mystic_snake_cast_body.vpcf"
	-- effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN,  self.caster )
	-- ParticleManager:SetParticleControl( effect_cast, 1, self.caster:GetOrigin() )
	-- ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	-- ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.speed, 0, 0 ) )

	-- -- buff particle
	-- self:AddParticle(
	-- 	effect_cast,
	-- 	false, -- bDestroyImmediately
	-- 	false, -- bStatusEffect
	-- 	-1, -- iPriority
	-- 	false, -- bHeroEffect
	-- 	false -- bOverheadEffect
	--)
	self:GetCaster():EmitSound("Hero_Medusa.MysticSnake.Return")
		
	local particle_snake = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile_return.vpcf", PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(particle_snake, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle_snake, 1, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_snake, 2, Vector(self.speed, 0, 0))

	-- self:AddParticle(
	-- 	particle_snake,
	-- 	false, -- bDestroyImmediately
	-- 	false, -- bStatusEffect
	-- 	-1, -- iPriority
	-- 	false, -- bHeroEffect
	-- 	false -- bOverheadEffect
	-- )
end