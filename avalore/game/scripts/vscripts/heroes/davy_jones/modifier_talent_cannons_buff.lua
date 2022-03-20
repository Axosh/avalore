modifier_talent_cannons_buff = class({})

function modifier_talent_cannons_buff:IsHidden() 		return false end
function modifier_talent_cannons_buff:IsPurgable() 		return false end
function modifier_talent_cannons_buff:RemoveOnDeath() 	return true end

function modifier_talent_cannons_buff:GetTexture()
    return "davy_jones/cannons"
end

function modifier_talent_cannons_buff:OnCreated(kv)
    local caster = self:GetCaster()
    self.interval = caster:FindTalentValue("talent_cannons", "attack_interval")
    self.damage = caster:FindTalentValue("talent_cannons", "damage")
    self.range = caster:FindTalentValue("talent_cannons", "range")
    self.projectile_speed = caster:FindTalentValue("talent_cannons", "projectile_speed")

    if not IsServer() then return end

    self.parent = self:GetParent()
    self.damageTable = {
		-- victim = target,
		attacker = self:GetParent(),
		-- damage = self:GetAbility():GetAbilityDamage(),
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = self:GetCaster():FindAbilityByName("talent_cannons"), --Optional.
	}

    self:StartIntervalThink(self.interval)
    self:OnIntervalThink()
end

function modifier_talent_cannons_buff:OnIntervalThink()
    local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    local enemy = nil
	if #enemies>0 then
		enemy = enemies[1]

		-- apply damage
		-- self.damageTable.victim = enemy
        -- self.damageTable.damage = self.damage
        -- ApplyDamage( self.damageTable )

        local info = {
            Target = enemy,
            Source = self:GetCaster(),
            Ability = self:GetCaster():FindAbilityByName("talent_cannons"),
            EffectName = "particles/econ/events/coal/coal_projectile.vpcf",
            iMoveSpeed = self.projectile_speed,
            dDodgeable = false,
            bVisibleToEnemies = true,
            bProvidesVision = true,
            iVisionRadius = 250,
            iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
        }
        ProjectileManager:CreateTrackingProjectile(info)
	end

    -- trying to sync damage with collsion since OnProjectileHit doesn't seem to work with modifiers
    Timers:CreateTimer(1.0, function()
        -- apply damage
		self.damageTable.victim = enemy
        self.damageTable.damage = self.damage
        ApplyDamage( self.damageTable )
    end)
end

-- NOTE: OnProjectileHit only works for abilities, not modifiers
-- function modifier_talent_cannons_buff:OnProjectileHit(target, location)
--     if not target then return end

--     print("Cannons => " .. target:GetName() .. " for " .. tostring(self.damage))

--     -- apply damage
--     self.damageTable.victim = target
--     self.damageTable.damage = self.damage
--     ApplyDamage( self.damageTable )
-- end

-- function modifier_talent_cannons_buff:PlayEffects(target, radius)
--     local particle_cast = "particles/econ/events/coal/coal_projectile.vpcf"
--     local sound_cast = "" -- tbd

--     local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
-- 	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

--     --EmitSoundOn( sound_cast, self:GetCaster() )
-- end