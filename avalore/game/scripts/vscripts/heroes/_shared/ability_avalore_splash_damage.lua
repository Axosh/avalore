ability_avalore_splash_damage = class({})

LinkLuaModifier("modifier_ability_avalore_splash_damage",   "scripts/vscripts/heroes/_shared/ability_avalore_splash_damage.lua", LUA_MODIFIER_MOTION_NONE)

function ability_avalore_splash_damage:GetIntrinsicModifierName()
    return "modifier_ability_avalore_splash_damage"
end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_ability_avalore_splash_damage = class({})

function modifier_ability_avalore_splash_damage:IsHidden() return true end
function modifier_ability_avalore_splash_damage:IsDebuff() return false end
function modifier_ability_avalore_splash_damage:IsPurgable() return false end
function modifier_ability_avalore_splash_damage:RemoveOnDeath() return false end


function modifier_ability_avalore_splash_damage:OnCreated(kv)
    self.splash_radius = self:GetAbility():GetSpecialValueFor( "splash_radius" )
	self.splash_pct = self:GetAbility():GetSpecialValueFor( "splash_damage_percent" )/100

    self.projectile = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"
	self.attack_sound = "Hero_DragonKnight.ElderDragonShoot2.Attack"
	-- self.scale = 10
end

function modifier_ability_avalore_splash_damage:DeclareFunctions()
    return {    MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
                MODIFIER_PROPERTY_PROJECTILE_NAME,
                MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
                MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
    }
end

-- function modifier_ability_avalore_splash_damage:GetModifierModelScale()
-- 	return self.scale
-- end

function modifier_ability_avalore_splash_damage:GetAttackSound()
	return self.attack_sound
end

function modifier_ability_avalore_splash_damage:GetModifierProjectileName()
	return self.projectile
end

function modifier_ability_avalore_splash_damage:GetModifierProjectileSpeedBonus()
	return 900
end

function modifier_ability_avalore_splash_damage:GetModifierProcAttack_Feedback( params )
	if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end
    self:Splash( params.target, params.damage )
    -- play effects
	local sound_cast = "Hero_DragonKnight.ProjectileImpact"
	EmitSoundOn( sound_cast, params.target )
end

function modifier_ability_avalore_splash_damage:Splash( target, damage )
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.splash_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		if enemy~=target then

			-- apply damage
			local damageTable = {
				victim = enemy,
				attacker = self:GetParent(),
				damage = damage * self.splash_pct,
				damage_type = DAMAGE_TYPE_PHYSICAL,
				ability = self:GetAbility(), --Optional.
			}
			ApplyDamage(damageTable)
		end
	end
end