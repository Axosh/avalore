item_vidars_shoes = class({})

LinkLuaModifier( "modifier_item_vidars_shoes", "items/shop/tier1/item_vidars_shoes.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_avalore_bash", "modifiers/base_spell/modifier_avalore_bash.lua", LUA_MODIFIER_MOTION_NONE)

function item_vidars_shoes:GetIntrinsicModifierName()
    return "modifier_item_vidars_shoes"
end

function item_vidars_shoes:OnSpellStart()

    self.mini_bash = self:GetSpecialValueFor("mini_bash")
    self.bash_dmg  = self:GetSpecialValueFor("bash_dmg")

    local sound_cast = "DOTA_Item.AbyssalBlade.Activate"
    local particle   = "particles/items_fx/abyssal_blade.vpcf"

    local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()

    EmitSoundOn(sound_cast, target)

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:TriggerSpellAbsorb(ability) then
			return nil
		end
	end

    -- Blink
    local blink_start_particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_start_particle)
	
	FindClearSpaceForUnit(self:GetCaster(), target:GetAbsOrigin() - self:GetCaster():GetForwardVector() * 56, false)
	
	local blink_end_particle = ParticleManager:CreateParticle("particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(blink_end_particle)

    -- Stun Particle
    local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_fx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_fx)

    -- Apply damage
	local damageTable = {
		victim      = target,
		attacker    = caster,
		damage      = self.bash_dmg,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability     = self
	}

	ApplyDamage(damageTable)

    if target:IsAlive() then
        local bash_dur = (self.mini_bash * (1 - target:GetStatusResistance()))
        target:AddNewModifier(caster, ability, "modifier_avalore_bash", {duration = bash_dur})
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_vidars_shoes = modifier_item_vidars_shoes or class({})

function modifier_item_vidars_shoes:IsHidden() return true end
function modifier_item_vidars_shoes:IsDebuff() return false end
function modifier_item_vidars_shoes:IsPurgable() return false end
function modifier_item_vidars_shoes:RemoveOnDeath() return false end

function modifier_item_vidars_shoes:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_item_vidars_shoes:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.bonus_str          = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_dmg          = self.item_ability:GetSpecialValueFor("bonus_damage")
    self.bonus_move_speed   = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_armor        = self.item_ability:GetSpecialValueFor("bonus_armor")
end

function modifier_item_vidars_shoes:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_vidars_shoes:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_vidars_shoes:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_vidars_shoes:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end