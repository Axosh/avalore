item_avalore_gleipnir = class({})

LinkLuaModifier( "modifier_item_avalore_gleipnir", "items/shop/tier4/item_avalore_gleipnir.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_avalore_gleipnir_debuff", "items/shop/tier4/item_avalore_gleipnir.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_arcane_amplification", "items/shop/base_materials/item_essence_of_arcane.lua", LUA_MODIFIER_MOTION_NONE )

function item_avalore_gleipnir:GetIntrinsicModifierName()
    return "modifier_item_avalore_gleipnir"
end

function item_avalore_gleipnir:OnSpellStart()
    self.caster		= self:GetCaster()
    -- Values
    self.duration				=	self:GetSpecialValueFor("cast_duration")
	self.tooltip_range			=	self:GetSpecialValueFor("tooltip_range")
	self.projectile_speed		=	self:GetSpecialValueFor("projectile_speed")

    if not IsServer() then return end
	
	local caster_location	= self.caster:GetAbsOrigin()
	local target			= self:GetCursorPosition()

    -- Play the cast sound
	self.caster:EmitSound("DOTA_Item.Gleipnir.Cast")

    local direction = (target - self.caster:GetAbsOrigin()):Normalized()
	local DummyUnit = CreateUnitByName("npc_dummy_unit",target,false,self.caster,self.caster:GetOwner(),self.caster:GetTeamNumber())
	DummyUnit:AddNewModifier(self.caster, self, "modifier_kill", {duration = 0.1})
	local cast_target = DummyUnit

    local projectile = {
        Target 				= cast_target,
        Source 				= self.caster,
        Ability 			= self,
        EffectName 			= "particles/items3_fx/gleipnir_projectile.vpcf",
        iMoveSpeed			= self.projectile_speed,
        vSourceLoc 			= direction, --caster_location,
        bDrawsOnMinimap 	= false,
        bDodgeable 			= true,
        bIsAttack 			= false,
        bVisibleToEnemies 	= true,
        bReplaceExisting 	= false,
        flExpireTime 		= GameRules:GetGameTime() + 10,
        bProvidesVision 	= false,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
    }

    ProjectileManager:CreateTrackingProjectile(projectile)
end

function item_avalore_gleipnir:GetAOERadius()
	return self:GetSpecialValueFor("debuff_radius")
end

function item_avalore_gleipnir:OnProjectileHit(hTarget, vLocation)
    if not IsServer() then return end

    local location = vLocation
	if hTarget then
		location = hTarget:GetAbsOrigin()
	end

    -- Find units around the target point
	local enemies =   FindUnitsInRadius(self.caster:GetTeamNumber(),
                                        location,
                                        nil,
                                        self:GetSpecialValueFor("debuff_radius"),
                                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                                        0,
                                        FIND_ANY_ORDER,
                                        false)
	
    self.magic_dmg_amp      = self:GetSpecialValueFor("magic_dmg_amp")
    self.orb_duration       = self:GetSpecialValueFor("orb_duration")                               
    for _,unit in pairs(enemies) do
        -- Check if a valid target has been hit
        if not unit:IsMagicImmune() then
            unit:EmitSound("DOTA_Item.Gleipnir.Target")

            unit:AddNewModifier(self.caster, self, "modifier_item_avalore_gleipnir_debuff", {duration = self.duration * (1 - unit:GetStatusResistance())})

            local dur_resist        = self.orb_duration * (1 - unit:GetStatusResistance())
            unit:AddNewModifier(self.caster, self, "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
        end
    end
    return true
end


-- ====================================
-- INTRINSIC MOD
-- ====================================

modifier_item_avalore_gleipnir = modifier_item_avalore_gleipnir or class({})

function modifier_item_avalore_gleipnir:IsHidden() return true end
function modifier_item_avalore_gleipnir:IsDebuff() return false end
function modifier_item_avalore_gleipnir:IsPurgable() return false end
function modifier_item_avalore_gleipnir:RemoveOnDeath() return false end

-- allow multiple of this item bonuses to stack
function modifier_item_avalore_gleipnir:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_avalore_gleipnir:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
                MODIFIER_PROPERTY_HEALTH_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_item_avalore_gleipnir:OnCreated(event)
    self.item_ability       = self:GetAbility()
    self.bonus_str          = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi          = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int          = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_mana_regen   = self.item_ability:GetSpecialValueFor("passive_mana_regen")
    self.orb_duration       = self.item_ability:GetSpecialValueFor("orb_duration")
    self.magic_dmg_amp      = self.item_ability:GetSpecialValueFor("magic_dmg_amp")
    self.bonus_hp           = self.item_ability:GetSpecialValueFor("bonus_hp")
    self.bonus_hp_regen     = self.item_ability:GetSpecialValueFor("bonus_hp_regen")
end

function modifier_item_avalore_gleipnir:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_avalore_gleipnir:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_avalore_gleipnir:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_avalore_gleipnir:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_avalore_gleipnir:OnAttackLanded(kv)
    local caster = self:GetCaster()
    if kv.attacker == caster then
        local dur_resist = self.orb_duration * (1 - kv.target:GetStatusResistance())
        kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_arcane_amplification", {duration = dur_resist, magic_dmg_amp = self.magic_dmg_amp})
    end
end

function modifier_item_avalore_gleipnir:GetModifierHealthBonus()
    return self.bonus_hp
end

function modifier_item_avalore_gleipnir:GetModifierConstantHealthRegen()
    return self.bonus_hp_regen
end

-- ====================================
-- DEBUFF MOD
-- ====================================

modifier_item_avalore_gleipnir_debuff = modifier_item_avalore_gleipnir_debuff or class({})

function modifier_item_avalore_gleipnir_debuff:GetTexture()
    return "items/gleipnir_orig"
end

function modifier_item_avalore_gleipnir_debuff:GetEffectName()
	return "particles/items3_fx/gleipnir_root.vpcf"
end

function modifier_item_avalore_gleipnir_debuff:CheckState(keys)
	return {
		[MODIFIER_STATE_ROOTED] = true
	}
end