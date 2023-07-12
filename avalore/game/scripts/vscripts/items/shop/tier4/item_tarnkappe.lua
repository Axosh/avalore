item_tarnkappe = class({})

LinkLuaModifier( "modifier_item_tarnkappe", "items/shop/tier4/item_tarnkappe.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_tarnkappe_invis", "items/shop/tier4/item_tarnkappe.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_tarnkappe_debuff", "items/shop/tier4/item_tarnkappe.lua", LUA_MODIFIER_MOTION_NONE )

function item_tarnkappe:GetIntrinsicModifierName()
    return "modifier_item_tarnkappe"
end

function item_tarnkappe:OnSpellStart()
    local caster    =   self:GetCaster()
	local particle_invis_start = "particles/generic_hero_status/status_invisibility_start.vpcf"

    local duration  =   self:GetSpecialValueFor("invis_duration")
	local fade_time =   self:GetSpecialValueFor("invis_fade_time")

    EmitSoundOn("DOTA_Item.InvisibilitySword.Activate", self:GetCaster())

    Timers:CreateTimer(fade_time, function()
		local particle_invis_start_fx = ParticleManager:CreateParticle(particle_invis_start, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_invis_start_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_invis_start_fx)

		caster:AddNewModifier(caster, self, "modifier_item_tarnkappe_invis", {duration = duration})
	end)

end

-- ====================================
-- INTRINSIC MOD
-- ====================================
modifier_item_tarnkappe = class({})

function modifier_item_tarnkappe:IsHidden() return true end
function modifier_item_tarnkappe:IsDebuff() return false end
function modifier_item_tarnkappe:IsPurgable() return false end
function modifier_item_tarnkappe:RemoveOnDeath() return false end
function modifier_item_tarnkappe:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_tarnkappe:DeclareFunctions()
    return {    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
                MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
                MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
                MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE      }
end

function modifier_item_tarnkappe:OnCreated(event)
    self.item_ability = self:GetAbility()
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_agi = self.item_ability:GetSpecialValueFor("bonus_agi")
    self.bonus_int = self.item_ability:GetSpecialValueFor("bonus_int")
    self.bonus_armor = self.item_ability:GetSpecialValueFor("bonus_armor")
    self.bonus_dmg = self.item_ability:GetSpecialValueFor("bonus_dmg")
    self.bonus_move_speed = self.item_ability:GetSpecialValueFor("bonus_movement_speed")
    self.bonus_str = self.item_ability:GetSpecialValueFor("bonus_str")
    self.bonus_hp_regen_pct = self.item_ability:GetSpecialValueFor("bonus_hp_regen_pct")
end

function modifier_item_tarnkappe:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_tarnkappe:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_tarnkappe:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_tarnkappe:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_item_tarnkappe:GetModifierPreAttack_BonusDamage()
    return self.bonus_dmg
end

function modifier_item_tarnkappe:GetModifierMoveSpeedBonus_Constant()
    return self.bonus_move_speed
end

function modifier_item_tarnkappe:GetModifierHealthRegenPercentage()
    return self.bonus_hp_regen_pct
end


-- ====================================
-- ACTIVE MOD
-- ====================================

modifier_item_tarnkappe_invis = class({})

function modifier_item_tarnkappe_invis:IsDebuff() return false end
function modifier_item_tarnkappe_invis:IsHidden() return false end
function modifier_item_tarnkappe_invis:IsPurgable() return false end

function modifier_item_tarnkappe_invis:OnCreated(params)
    if not self:GetAbility() then self:Destroy() return end
    self.invis_ms_pct = self:GetAbility():GetSpecialValueFor("invis_ms_pct")
    self.bonus_dmg_crit = self:GetAbility():GetSpecialValueFor("bonus_dmg_crit")
end

function modifier_item_tarnkappe_invis:GetTexture()
    return "items/tarnkappe_orig"
end

function modifier_item_tarnkappe_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE]			= true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end

function modifier_item_tarnkappe_invis:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_item_tarnkappe_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_tarnkappe_invis:GetModifierMoveSpeedBonus_Percentage()
    return self.invis_ms_pct
end

function modifier_item_tarnkappe_invis:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then

            params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_tarnkappe_debuff", {duration = break_duration * (1 - params.target:GetStatusResistance())})

            self:GetParent():EmitSound("Imba.SilverEdgeInvisAttack")

            local attack_particle	=	"particles/item/silver_edge/imba_silver_edge.vpcf"
            local particle_fx = ParticleManager:CreateParticle(attack_particle, PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(particle_fx, 0, params.target:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle_fx)

			self:Destroy()
		end
	end
end

function modifier_item_tarnkappe_invis:OnAbilityExecuted( keys )
	if IsServer() then
		local parent =	self:GetParent()
		-- Remove the invis on cast
		if keys.unit == parent then
			self:Destroy()
		end
	end
end

function modifier_item_tarnkappe_invis:GetModifierPreAttack_BonusDamage()
	return self.bonus_dmg_crit
end

-- ====================================
-- DEBUFF MOD
-- ====================================

modifier_item_tarnkappe_debuff = class({})

function modifier_item_tarnkappe_debuff:IsDebuff() return false end
function modifier_item_tarnkappe_debuff:IsHidden() return false end
function modifier_item_tarnkappe_debuff:IsPurgable() return false end

function modifier_item_tarnkappe_debuff:OnCreated()
    self.debuff_dmg_reduction = self:GetAbility():GetSpecialValueFor("debuff_dmg_reduction")
end


function modifier_item_tarnkappe_debuff:CheckState()
	return {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}
end

function modifier_item_tarnkappe_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end

function modifier_item_tarnkappe_debuff:GetModifierTotalDamageOutgoing_Percentage()
    return self.debuff_dmg_reduction
end