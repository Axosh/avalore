item_seal_of_soloman = class({})

LinkLuaModifier( "modifier_item_seal_of_soloman", "items/shop/tier2/item_seal_of_soloman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_seal_of_soloman_debuff", "items/shop/tier2/item_seal_of_soloman.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arcane_amplification", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )

function item_seal_of_soloman:GetIntrinsicModifierName()
    return "modifier_item_seal_of_soloman"
end

function item_seal_of_soloman:OnSpellStart()
    self.caster		= self:GetCaster()
    -- Values
    self.duration				=	self:GetSpecialValueFor("cast_duration")
	self.tooltip_range			=	self:GetSpecialValueFor("tooltip_range")
	self.projectile_speed		=	self:GetSpecialValueFor("projectile_speed")

    if not IsServer() then return end
	
	local caster_location	= self.caster:GetAbsOrigin()
	local target			= self:GetCursorTarget()

    -- Play the cast sound
	self.caster:EmitSound("DOTA_Item.RodOfAtos.Cast")

    local projectile = {
                            Target 				= target,
                            Source 				= self.caster,
                            Ability 			= self,
                            EffectName 			= "particles/items2_fx/rod_of_atos_attack.vpcf",
                            iMoveSpeed			= self.projectile_speed,
                            vSourceLoc 			= caster_location,
                            bDrawsOnMinimap 	= false,
                            bDodgeable 			= true,
                            bIsAttack 			= false,
                            bVisibleToEnemies 	= true,
                            bReplaceExisting 	= false,
                            flExpireTime 		= GameRules:GetGameTime() + 20,
                            bProvidesVision 	= false,
                        }
				
    ProjectileManager:CreateTrackingProjectile(projectile)
end

function item_seal_of_soloman:OnProjectileHit(target, location)
    if not IsServer() then return end
	
	-- Check if a valid target has been hit
	if target and not target:IsMagicImmune() then
        -- check for linkens/lotus effect
        if target:TriggerSpellAbsorb(self) then return nil end

        target:EmitSound("DOTA_Item.RodOfAtos.Target")

        target:AddNewModifier(self.caster, self, "modifier_item_seal_of_soloman_debuff", {duration = self.duration * (1 - target:GetStatusResistance())})
        self.magic_dmg_amp      = self:GetSpecialValueFor("magic_dmg_amp")
        self.orb_duration       = self:GetSpecialValueFor("orb_duration")

        local dur_resist        = self.orb_duration * (1 - target:GetStatusResistance())
        target:AddNewModifier(self.caster, self, "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end

-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_seal_of_soloman = modifier_item_seal_of_soloman or class({})

function modifier_item_seal_of_soloman:IsHidden() return true end
function modifier_item_seal_of_soloman:IsDebuff() return false end
function modifier_item_seal_of_soloman:IsPurgable() return false end
function modifier_item_seal_of_soloman:RemoveOnDeath() return false end

function modifier_item_seal_of_soloman:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT }
end

function modifier_item_seal_of_soloman:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen   = self.item_ability:GetSpecialValueFor("passive_mana_regen")
    self.orb_duration           = self.item_ability:GetSpecialValueFor("orb_duration")
    self.magic_dmg_amp      = self.item_ability:GetSpecialValueFor("magic_dmg_amp")
end

function modifier_item_seal_of_soloman:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_seal_of_soloman:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_seal_of_soloman:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_seal_of_soloman:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_seal_of_soloman:OnAttackLanded(kv)
    local caster = self:GetCaster()
    if kv.attacker == caster then
        local dur_resist = self.orb_duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end

-- ====================================
-- DEBUFF
-- ====================================

modifier_item_seal_of_soloman_debuff = modifier_item_seal_of_soloman_debuff or class({})

function modifier_item_seal_of_soloman_debuff:GetTexture()
    return "items/seal_of_soloman_orig"
end

function modifier_item_seal_of_soloman_debuff:GetEffectName()
	return "particles/items2_fx/rod_of_atos.vpcf"
end

function modifier_item_seal_of_soloman_debuff:CheckState(keys)
	return {
		[MODIFIER_STATE_ROOTED] = true
	}
end