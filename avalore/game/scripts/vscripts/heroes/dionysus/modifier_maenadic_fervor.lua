modifier_maenadic_fervor = class({})

function modifier_maenadic_fervor:IsHidden() return false end
function modifier_maenadic_fervor:IsPurgable() return true end
function modifier_maenadic_fervor:RemoveOnDeath() return true end

-- depending on who its cast on, will be a boon or bane
function modifier_maenadic_fervor:IsDebuff()
    return self.isDebuff
end

function modifier_maenadic_fervor:OnCreated( kv )
	self:GetAbilityValues()
end

function modifier_maenadic_fervor:OnRefresh( kv )
	self:GetAbilityValues()
end

function modifier_maenadic_fervor:GetAbilityValues()
    if not IsServer() then return end
    -- buff allies
    if self:GetParent():GetTeam() == self:GetCaster():GetTeam() then
	    self.isDebuff = false
	    self.dmg_out_amp = self:GetAbility():GetSpecialValueFor( "damage_outgoing_increase_buff_pct" )
        self.dmg_in_amp  = self:GetAbility():GetSpecialValueFor( "damage_incoming_increase_buff_pct" )
        self.as_amp      = self:GetAbility():GetSpecialValueFor("attack_speed_increase_buff_pct")
    else
        self.isDebuff = true
	    self.dmg_out_amp = self:GetAbility():GetSpecialValueFor( "damage_outgoing_increase_debuff_pct" )
        self.dmg_in_amp  = self:GetAbility():GetSpecialValueFor( "damage_incoming_increase_debuff_pct" )
        self.as_amp      = self:GetAbility():GetSpecialValueFor("attack_speed_increase_debuff_pct")
    end
end


function modifier_maenadic_fervor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end


function modifier_maenadic_fervor:GetModifierDamageOutgoing_Percentage()
    return self.dmg_out_amp
end
function modifier_maenadic_fervor:GetModifierIncomingDamage_Percentage()
    return self.dmg_in_amp
end
function modifier_maenadic_fervor:GetModifierAttackSpeedBonus_Constant(kv)
    return self.as_amp
end

function modifier_maenadic_fervor:GetEffectName()
    return "particles/econ/courier/courier_ti10/courier_ti10_lvl4_dire_ambient_fly.vpcf"
    --return "particles/dire_fx/dire_tower_decay_streaks.vpcf"
end

function modifier_maenadic_fervor:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
