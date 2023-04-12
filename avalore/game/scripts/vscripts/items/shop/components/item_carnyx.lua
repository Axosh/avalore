item_carnyx = class({})

LinkLuaModifier( "modifier_item_carnyx", "items/shop/components/item_carnyx.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_avalore_bash", "modifiers/base_spell/modifier_avalore_bash.lua", LUA_MODIFIER_MOTION_NONE)

function item_carnyx:GetIntrinsicModifierName()
    return "modifier_item_carnyx"
end

function item_carnyx:OnSpellStart()

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

modifier_item_carnyx = modifier_item_carnyx or class({})

function modifier_item_carnyx:IsHidden() return true end
function modifier_item_carnyx:IsDebuff() return false end
function modifier_item_carnyx:IsPurgable() return false end
function modifier_item_carnyx:RemoveOnDeath() return false end

function modifier_item_carnyx:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_carnyx:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_carnyx:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_carnyx:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end