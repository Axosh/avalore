item_seal_of_solomon = class({})

LinkLuaModifier( "modifier_item_seal_of_solomon", "items/shop/tier4/item_seal_of_solomon.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_seal_of_solomon_debuff", "items/shop/tier4/item_seal_of_solomon.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_seal_of_solomon_dispel", "items/shop/tier4/item_seal_of_solomon.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_seal_of_solomon_slow", "items/shop/tier4/item_seal_of_solomon.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arcane_amplification", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )

function item_seal_of_solomon:GetIntrinsicModifierName()
    return "modifier_item_seal_of_solomon"
end

function item_seal_of_solomon:OnSpellStart()
    self.caster		= self:GetCaster()
    -- Values
    self.duration				=	self:GetSpecialValueFor("cast_duration")
	self.tooltip_range			=	self:GetSpecialValueFor("tooltip_range")
	self.projectile_speed		=	self:GetSpecialValueFor("projectile_speed")

    if not IsServer() then return end
	
	local caster_location	= self.caster:GetAbsOrigin()
	local target			= self:GetCursorTarget()

    -- Play the cast sound
	self:GetCaster():EmitSound("DOTA_Item.Nullifier.Cast")

    local projectile = {
                            Target 				= target,
                            Source 				= self.caster,
                            Ability 			= self,
                            EffectName 			= "particles/items4_fx/nullifier_proj.vpcf",
                            iMoveSpeed			= self.projectile_speed,
                            vSourceLoc 			= caster_location,
                            bDrawsOnMinimap 	= false,
                            bDodgeable 			= true,
                            bIsAttack 			= false,
                            bVisibleToEnemies 	= true,
                            bReplaceExisting 	= false,
                            flExpireTime 		= GameRules:GetGameTime() + 10,
                            bProvidesVision 	= false,
                        }
				
    ProjectileManager:CreateTrackingProjectile(projectile)
end

function item_seal_of_solomon:OnProjectileHit(target, location)
    if not IsServer() then return end
	
	-- Check if a valid target has been hit
	if target and not target:IsMagicImmune() then
        -- check for linkens/lotus effect
        if target:TriggerSpellAbsorb(self) then return nil end

        target:EmitSound("DOTA_Item.Nullifier.Target")

        target:Purge(true, false, false, false, false)

        target:AddNewModifier(self.caster, self, "modifier_item_seal_of_solomon_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
        self.magic_dmg_amp      = self:GetSpecialValueFor("magic_dmg_amp")
        self.orb_duration       = self:GetSpecialValueFor("orb_duration")

        local dur_resist        = self.orb_duration * (1 - target:GetStatusResistance())
        target:AddNewModifier(self.caster, self, "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})

        target:AddNewModifier(self:GetCaster(), self, "modifier_item_seal_of_solomon_dispel", {duration = self:GetSpecialValueFor("mute_duration") * (1 - target:GetStatusResistance())})

        -- not used right now, but maybe in the future
        if self:GetLevel() >= 2 then
			target:AddNewModifier(self:GetCaster(), self, "modifier_item_seal_of_solomon_mute", {duration = self:GetSpecialValueFor("mute_duration") * (1 - target:GetStatusResistance())})
        end
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_seal_of_solomon = modifier_item_seal_of_solomon or class({})

function modifier_item_seal_of_solomon:IsHidden() return true end
function modifier_item_seal_of_solomon:IsDebuff() return false end
function modifier_item_seal_of_solomon:IsPurgable() return false end
function modifier_item_seal_of_solomon:RemoveOnDeath() return false end

function modifier_item_seal_of_solomon:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_item_seal_of_solomon:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen   = self.item_ability:GetSpecialValueFor("passive_mana_regen")
    self.orb_duration       = self.item_ability:GetSpecialValueFor("orb_duration")
    self.magic_dmg_amp      = self.item_ability:GetSpecialValueFor("magic_dmg_amp")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
end

function modifier_item_seal_of_solomon:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_seal_of_solomon:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_seal_of_solomon:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_seal_of_solomon:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_seal_of_solomon:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_seal_of_solomon:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_seal_of_solomon:OnAttackLanded(kv)
    local caster = self:GetCaster()
    if kv.attacker == caster then
        local dur_resist = self.orb_duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end

-- ====================================
-- DEBUFF - Inherited
-- ====================================

modifier_item_seal_of_solomon_debuff = modifier_item_seal_of_solomon_debuff or class({})

function modifier_item_seal_of_solomon_debuff:GetTexture()
    return "items/seal_of_solomon_orig"
end

function modifier_item_seal_of_solomon_debuff:GetEffectName()
	return "particles/items2_fx/rod_of_atos.vpcf"
end

function modifier_item_seal_of_solomon_debuff:CheckState(keys)
	return {
		[MODIFIER_STATE_ROOTED] = true
	}
end

-- ====================================
-- DEBUFF - Dispel
-- ====================================

modifier_item_seal_of_solomon_dispel = modifier_item_seal_of_solomon_dispel or class({})

function modifier_item_seal_of_solomon_dispel:IsPurgable() return false end
function modifier_item_seal_of_solomon_dispel:IsPurgeException() return false end

function modifier_item_seal_of_solomon_dispel:GetTexture()
    return "items/seal_of_solomon_orig"
end

function modifier_item_seal_of_solomon_dispel:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier.vpcf"
end

function modifier_item_seal_of_solomon_dispel:OnCreated()
    if self:GetAbility() then
		self.slow_interval_duration = self:GetAbility():GetSpecialValueFor("slow_interval_duration")
	else
		self:Destroy()
		return
	end

    if not IsServer() then return end

    local overhead_particle = "particles/items4_fx/nullifier_mute.vpcf"

    local overhead_particle = ParticleManager:CreateParticle(overhead_particle, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	self:AddParticle(overhead_particle, false, false, -1, false, false)
	
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_seal_of_solomon_slow", {duration = self.slow_interval_duration * (1 - self:GetParent():GetStatusResistance())})
end

function modifier_item_seal_of_solomon_dispel:CheckState()
	if not IsServer() then return end

    self:GetParent():Purge(true, false, false, false, false)
end

function modifier_item_seal_of_solomon_dispel:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_item_seal_of_solomon_dispel:OnAttackLanded(keys)
	if not IsServer() then return end
	
	if keys.target == self:GetParent() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_seal_of_solomon_slow", {duration = self.slow_interval_duration * (1 - self:GetParent():GetStatusResistance())})
	end	
end

-- ====================================
-- DEBUFF - Slow
-- ====================================

modifier_item_seal_of_solomon_slow = modifier_item_seal_of_solomon_slow or class({})

function modifier_item_seal_of_solomon_slow:GetTexture()
    return "items/seal_of_solomon_orig"
end

function modifier_item_seal_of_solomon_slow:GetStatusEffectName()
	return "particles/status_fx/status_effect_nullifier_slow.vpcf"
end

function modifier_item_seal_of_solomon_slow:OnCreated()
	if IsServer() then
        if not self:GetAbility() then self:Destroy() end
    end

	self.slow_pct	= 0

	if self:GetAbility() then
		self.slow_pct	= self:GetAbility():GetSpecialValueFor("slow_pct") * (-1)
	end

	if not IsServer() then return end

	self:GetParent():EmitSound("DOTA_Item.Nullifier.Slow")
end

function modifier_item_seal_of_solomon_slow:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

-- Based on vanilla testing, the 100% slow modifier applies but doesn't slow if the item doesn't exist (i.e. you destroy it)
function modifier_item_seal_of_solomon_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_pct
end