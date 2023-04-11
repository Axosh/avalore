modifier_avalore_bash = modifier_avalore_bash or class({})

function modifier_avalore_bash:IsHidden()           return false end
function modifier_avalore_bash:IsPurgeException()   return true end
function modifier_avalore_bash:IsStunDebuff()       return true end

function modifier_avalore_bash:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_avalore_bash:GetEffectName()
	return "particles/generic_gameplay/generic_bashed.vpcf"
end

function modifier_avalore_bash:GetTexture()
    return "generic/bash"
end

function modifier_avalore_bash:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_avalore_bash:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_avalore_bash:GetOverrideAnimation()   
	return ACT_DOTA_DISABLED
end