modifier_thunder_clap_debuff = class({})

function modifier_thunder_clap_debuff:IsDebuff() return true end


function modifier_thunder_clap_debuff:OnCreated( kv )
	self.slow = self:GetAbility():GetSpecialValueFor("movement_slow")
end

function modifier_thunder_clap_debuff:OnRefresh( kv )
	self.slow = self:GetAbility():GetSpecialValueFor("movement_slow")
end

function modifier_thunder_clap_debuff:DeclareFunctions()
	return  {
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            }
end

function modifier_thunder_clap_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_thunder_clap_debuff:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifier_thunder_clap_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end