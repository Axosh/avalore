modifier_avalore_disarm = class({})

function modifier_avalore_disarm:IsHidden() return false end
function modifier_avalore_disarm:IsPurgeable() return true end
function modifier_avalore_disarm:IsDebuff() return true end

function modifier_avalore_disarm:GetTexture()
    return "generic/disarm"
end

function modifier_avalore_disarm:CheckState()
    return  {
                [MODIFIER_STATE_DISARMED] = true
            }
end

function modifier_avalore_disarm:GetEffectName()
	return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_avalore_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end